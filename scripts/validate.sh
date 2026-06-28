#!/usr/bin/env bash
# tempest conformance gate — the "Brand Check". Runs locally, in pre-commit, and in CI.
# Hard gates: shell syntax, JSON validity, skill frontmatter contract, command portability,
# manifest path integrity, no hardcoded home paths.
# Advisory (run only if installed): shellcheck.
# Exit nonzero if any hard gate fails.
set -uo pipefail
cd "$(dirname "$(readlink -f "$0")")/.." || exit 2

PLUGIN="plugins/tempest"

fail=0
ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$*"; fail=1; }
skip() { printf '  \033[33m–\033[0m %s\n' "$*"; }

echo "== shell syntax =="
while IFS= read -r f; do
  if bash -n "$f"; then ok "bash -n $f"; else bad "syntax error: $f"; fi
done < <(find . -name '*.sh' -not -path './.git/*' -not -path './node_modules/*' | sort)

echo "== shellcheck =="
if command -v shellcheck >/dev/null 2>&1; then
  while IFS= read -r f; do
    if shellcheck "$f"; then ok "shellcheck $f"; else bad "shellcheck: $f"; fi
  done < <(find . -name '*.sh' -not -path './.git/*' -not -path './node_modules/*' | sort)
else
  skip "shellcheck not installed"
fi

echo "== json validity =="
for j in .claude-plugin/marketplace.json "$PLUGIN/.claude-plugin/plugin.json" package.json; do
  if [ -f "$j" ] && python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$j"; then
    ok "valid JSON: $j"
  else
    bad "invalid or missing JSON: $j"
  fi
done

echo "== manifest path integrity =="
if python3 - <<'PY'; then ok "manifest paths resolve"; else bad "manifest path integrity failed"; fi
import json, os, sys
bad = 0
plugin_dir = "plugins/tempest"

# plugin.json: skills / commands dirs must exist
pj = json.load(open(f"{plugin_dir}/.claude-plugin/plugin.json"))
for key in ("skills", "commands"):
    rel = pj.get(key)
    if rel:
        path = os.path.normpath(os.path.join(plugin_dir, rel))
        if not os.path.isdir(path):
            print(f"    plugin.json {key} -> missing dir: {path}"); bad = 1

# package.json: pi.skills / pi.prompts paths must exist
pk = json.load(open("package.json"))
pi = pk.get("pi", {})
for key in ("skills", "prompts"):
    for rel in pi.get(key, []):
        if not os.path.isdir(rel):
            print(f"    package.json pi.{key} -> missing dir: {rel}"); bad = 1

# marketplace.json: each plugin source path must exist
mk = json.load(open(".claude-plugin/marketplace.json"))
for p in mk.get("plugins", []):
    src = p.get("source")
    if isinstance(src, str) and src.startswith("."):
        if not os.path.isdir(src):
            print(f"    marketplace.json source -> missing dir: {src}"); bad = 1

sys.exit(bad)
PY

echo "== skill frontmatter contract =="
if python3 - <<'PY'; then ok "all skills valid"; else bad "skill frontmatter contract failed"; fi
import glob, os, re, sys
bad = 0
skills = sorted(glob.glob("plugins/tempest/skills/*/SKILL.md"))
if not skills:
    print("    (no skills yet — gate passes on an empty pack)")
for p in skills:
    parent = os.path.basename(os.path.dirname(p))
    raw = open(p, encoding="utf-8").read()
    m = re.match(r"^---\n(.*?)\n---\n", raw, re.DOTALL)
    if not m:
        print(f"    missing/malformed frontmatter: {p}"); bad = 1; continue
    front = m.group(1)
    if len(m.group(0)) > 1024:
        print(f"    frontmatter > 1024 chars: {p}"); bad = 1
    name = re.search(r"^name:\s*(.+)$", front, re.M)
    desc = re.search(r"^description:\s*(.+)$", front, re.M)
    if not name:
        print(f"    missing 'name': {p}"); bad = 1
    else:
        n = name.group(1).strip()
        if not re.match(r"^[a-z0-9]+(-[a-z0-9]+)*$", n) or len(n) > 64:
            print(f"    invalid name (lowercase/numbers/hyphens, <=64): {p}"); bad = 1
        elif n != parent:
            print(f"    name '{n}' must match directory '{parent}': {p}"); bad = 1
    if not desc:
        print(f"    missing 'description': {p}"); bad = 1
    else:
        d = desc.group(1).strip()
        if len(d) > 1024:
            print(f"    description > 1024 chars: {p}"); bad = 1
        if not d.lower().startswith("use when"):
            print(f"    description should start with 'Use when' (trigger, not summary): {p}"); bad = 1
sys.exit(bad)
PY

echo "== command portability =="
if python3 - <<'PY'; then ok "all commands portable"; else bad "command portability failed"; fi
import glob, re, sys
bad = 0
cmds = sorted(glob.glob("plugins/tempest/commands/*.md"))
if not cmds:
    print("    (no commands yet — gate passes)")
for p in cmds:
    raw = open(p, encoding="utf-8").read()
    m = re.match(r"^---\n(.*?)\n---\n", raw, re.DOTALL)
    front = m.group(1) if m else ""
    body = raw[m.end():] if m else raw
    if not re.search(r"^description:\s*\S", front, re.M):
        print(f"    missing 'description' frontmatter: {p}"); bad = 1
    # Pi-only arg syntax: ${1:-default}, ${@:N}, $@  (Claude doesn't support these)
    if re.search(r"\$\{[@0-9]", body) or re.search(r"\$@", body):
        print(f"    pi-only arg syntax (use $ARGUMENTS / $1..$9 for portability): {p}"); bad = 1
    # Claude-only frontmatter keys that pi ignores — warn so it's intentional, not accidental.
    for key in ("allowed-tools", "model"):
        if re.search(rf"^{key}:", front, re.M):
            print(f"    note: Claude-only frontmatter '{key}' (ignored by pi): {p}"); bad = 1
sys.exit(bad)
PY

echo "== no hardcoded home paths =="
hits="$(grep -RnE '(/home/|/Users/)[A-Za-z0-9]' \
  --exclude-dir=.git --exclude-dir=node_modules \
  --include='*.sh' --include='*.md' --include='*.json' --include='*.yaml' --include='*.yml' . \
  | grep -v '\.git/' || true)"
if [ -n "$hits" ]; then
  bad "hardcoded home paths found:"
  printf '%s\n' "$hits" | sed 's/^/      /'
else
  ok "no hardcoded home/user paths in tracked files"
fi

echo
if [ "$fail" -ne 0 ]; then
  echo "CONFORMANCE: FAIL"
  exit 1
fi
echo "CONFORMANCE: PASS"

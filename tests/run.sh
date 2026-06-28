#!/usr/bin/env bash
# ascension test suite. Installs into throwaway harness homes and asserts the wiring.
# No network, no agent CLIs needed. Exit nonzero on any failed assertion.
set -uo pipefail
REPO="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
SKILLS_SRC="$REPO/plugins/ascension/skills"
CMDS_SRC="$REPO/plugins/ascension/commands"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail=0
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
bad() { printf '  \033[31m✗\033[0m %s\n' "$*"; fail=1; }

A="$TMP/agents"; C="$TMP/claude"; P="$TMP/pi"
run_install() { AGENTS_HOME="$A" CLAUDE_HOME="$C" PI_HOME="$P" bash "$REPO/install.sh"; }

echo "== install into sandbox =="
run_install >/dev/null 2>&1 || bad "install.sh exited nonzero"
[ -d "$A/skills" ]   && ok "created agents/skills" || bad "missing agents/skills"
[ -d "$C/skills" ]   && ok "created claude/skills" || bad "missing claude/skills"
[ -d "$C/commands" ] && ok "created claude/commands" || bad "missing claude/commands"
[ -f "$P/settings.json" ] && ok "wrote pi settings.json" || bad "missing pi settings.json"
python3 -c "import json; json.load(open('$P/settings.json'))" 2>/dev/null \
  && ok "pi settings.json valid JSON" || bad "pi settings.json invalid"
python3 -c "import json,sys; d=json.load(open('$P/settings.json')); sys.exit(0 if '$CMDS_SRC' in d.get('prompts',[]) else 1)" \
  && ok "pi prompt path registered" || bad "pi prompt path not registered"

echo "== every skill is linked into both neutral and Claude locations =="
for s in "$SKILLS_SRC"/*/; do
  [ -d "$s" ] || continue
  name="$(basename "$s")"
  [ -L "$A/skills/$name" ] && ok "agents/skills/$name linked" || bad "skill $name not in agents/skills"
  [ -L "$C/skills/$name" ] && ok "claude/skills/$name linked" || bad "skill $name not in claude/skills"
  [ -f "$A/skills/$name/SKILL.md" ] && ok "$name/SKILL.md resolves" || bad "$name/SKILL.md does not resolve"
done

echo "== plan slice is present and wired =="
[ -f "$SKILLS_SRC/plan/SKILL.md" ] && ok "plan skill exists in repo" || bad "plan skill missing from repo"
[ -L "$C/skills/plan" ] && ok "plan skill wired into Claude" || bad "plan skill not wired into Claude"
[ -L "$C/commands/plan.md" ] && ok "plan command wired into Claude" || bad "plan command not wired"

echo "== idempotent re-install =="
run_install >/dev/null 2>&1 || bad "re-install exited nonzero"
n=$(python3 -c "import json; print(len(json.load(open('$P/settings.json')).get('prompts',[])))" 2>/dev/null)
[ "$n" = "1" ] && ok "no duplicate pi prompt path on re-run" || bad "pi prompt path duplicated (count=$n)"

echo "== uninstall removes our wiring =="
AGENTS_HOME="$A" CLAUDE_HOME="$C" PI_HOME="$P" bash "$REPO/uninstall.sh" >/dev/null 2>&1 || bad "uninstall.sh exited nonzero"
[ ! -e "$C/skills/plan" ] && ok "plan skill link removed from Claude" || bad "plan skill link not removed"
[ ! -e "$C/commands/plan.md" ] && ok "plan command link removed" || bad "plan command link not removed"
m=$(python3 -c "import json; print(len(json.load(open('$P/settings.json')).get('prompts',[])))" 2>/dev/null)
[ "$m" = "0" ] && ok "pi prompt path removed" || bad "pi prompt path not removed (count=$m)"

echo
if [ "$fail" -ne 0 ]; then
  echo "TESTS: FAIL"
  exit 1
fi
echo "TESTS: PASS"

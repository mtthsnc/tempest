#!/usr/bin/env bash
# ascension — uninstaller. Removes the wiring this repo created. Only removes symlinks
# that actually point back into this repo, so it is safe alongside other tools.
#
# Usage:
#   ./uninstall.sh
set -euo pipefail

REPO="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
SKILLS_SRC="$REPO/plugins/ascension/skills"
CMDS_SRC="$REPO/plugins/ascension/commands"

AGENTS_HOME="${AGENTS_HOME:-$HOME/.agents}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
PI_HOME="${PI_HOME:-$HOME/.pi/agent}"

say() { printf '  %s\n' "$*"; }

# Remove skill symlinks (only those pointing at this repo) from a target dir.
unlink_skills() {
  local dest="$1"
  [ -d "$dest" ] || return 0
  for s in "$SKILLS_SRC"/*/; do
    [ -d "$s" ] || continue
    local name link; name="$(basename "$s")"; link="$dest/$name"
    if [ -L "$link" ] && [ "$(readlink -f "$link")" = "$(readlink -f "${s%/}")" ]; then
      rm -f "$link"; say "removed skill link $dest/$name"
    fi
  done
}

unlink_skills "$AGENTS_HOME/skills"
unlink_skills "$CLAUDE_HOME/skills"

# Claude command symlinks.
if [ -d "$CMDS_SRC" ] && [ -d "$CLAUDE_HOME/commands" ]; then
  for c in "$CMDS_SRC"/*.md; do
    [ -e "$c" ] || continue
    link="$CLAUDE_HOME/commands/$(basename "$c")"
    if [ -L "$link" ] && [ "$(readlink -f "$link")" = "$(readlink -f "$c")" ]; then
      rm -f "$link"; say "removed command link $(basename "$c")"
    fi
  done
fi

# pi prompt path out of settings.json.
PI_SETTINGS="$PI_HOME/settings.json"
if [ -f "$PI_SETTINGS" ]; then
  python3 - "$PI_SETTINGS" "$CMDS_SRC" <<'PY'
import json, sys
path, cmds = sys.argv[1], sys.argv[2]
try:
    with open(path) as f: data = json.load(f)
except Exception:
    sys.exit(0)
prompts = data.get("prompts", [])
if cmds in prompts:
    prompts[:] = [p for p in prompts if p != cmds]
    if not prompts:
        data.pop("prompts", None)
    with open(path, "w") as f:
        json.dump(data, f, indent=2); f.write("\n")
    print(f"  removed pi prompt path: {cmds}")
PY
fi

echo "ascension: uninstalled."

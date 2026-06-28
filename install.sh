#!/usr/bin/env bash
# tempest — installer. Wires this skill pack into your agent harnesses.
# Idempotent: safe to re-run after `git pull`. No personal data is written into the repo.
#
# What it does:
#   - Neutral:  symlinks each skill into ~/.agents/skills/  (pi reads this natively; Codex later)
#   - Claude:   symlinks each skill into ~/.claude/skills/ and each command into ~/.claude/commands/
#   - pi:       registers the commands dir as a prompt-template path in ~/.pi/agent/settings.json
#               (pi picks up the skills via ~/.agents/skills)
#
# Usage:
#   ./install.sh                # all harnesses
#   ./install.sh --no-claude    # skip Claude Code wiring
#   ./install.sh --no-pi        # skip pi wiring
#
# Note: Claude Code can alternatively install this via the plugin marketplace
#   (/plugin marketplace add mtthsnc/tempest ; /plugin install tempest@tempest).
#   This script does the symlink path so it is scriptable and testable.
set -euo pipefail

REPO="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
SKILLS_SRC="$REPO/plugins/tempest/skills"
CMDS_SRC="$REPO/plugins/tempest/commands"

AGENTS_HOME="${AGENTS_HOME:-$HOME/.agents}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
PI_HOME="${PI_HOME:-$HOME/.pi/agent}"

WANT_CLAUDE=1; WANT_PI=1
for arg in "$@"; do
  case "$arg" in
    --no-claude) WANT_CLAUDE=0 ;;
    --no-pi) WANT_PI=0 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown arg: $arg" >&2; exit 2 ;;
  esac
done

say() { printf '  %s\n' "$*"; }
echo "tempest: installing from $REPO"

# link_skill <target-skills-dir> — symlink every skill dir into target, backing up real dirs.
link_skills() {
  local dest="$1"; mkdir -p "$dest"
  [ -d "$SKILLS_SRC" ] || return 0
  for s in "$SKILLS_SRC"/*/; do
    [ -d "$s" ] || continue
    local name link; name="$(basename "$s")"; link="$dest/$name"
    if [ -L "$link" ]; then
      rm -f "$link"
    elif [ -e "$link" ]; then
      mv "$link" "$link.pre-tempest.bak"; say "backed up existing $name -> $name.pre-tempest.bak"
    fi
    ln -sfn "${s%/}" "$link"
  done
}

# 1. Neutral target — pi reads ~/.agents/skills/ natively (so does Codex, later).
link_skills "$AGENTS_HOME/skills"
say "linked skills -> $AGENTS_HOME/skills"

# 2. Claude Code — skills + commands as symlinks.
if [ "$WANT_CLAUDE" -eq 1 ]; then
  link_skills "$CLAUDE_HOME/skills"
  mkdir -p "$CLAUDE_HOME/commands"
  if [ -d "$CMDS_SRC" ]; then
    for c in "$CMDS_SRC"/*.md; do
      [ -e "$c" ] || continue
      ln -sfn "$c" "$CLAUDE_HOME/commands/$(basename "$c")"
    done
  fi
  say "linked skills -> $CLAUDE_HOME/skills and commands -> $CLAUDE_HOME/commands"
else
  say "skipped Claude wiring (--no-claude)"
fi

# 3. pi — register the commands dir as a prompt-template path (skills come via ~/.agents/skills).
if [ "$WANT_PI" -eq 1 ]; then
  mkdir -p "$PI_HOME"
  PI_SETTINGS="$PI_HOME/settings.json"
  python3 - "$PI_SETTINGS" "$CMDS_SRC" <<'PY'
import json, os, sys
path, cmds = sys.argv[1], sys.argv[2]
try:
    with open(path) as f: data = json.load(f)
except Exception:
    data = {}
prompts = data.setdefault("prompts", [])
if cmds in prompts:
    print("  pi prompt path already registered")
else:
    prompts.append(cmds)
    print(f"  registered pi prompt path: {cmds}")
os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w") as f:
    json.dump(data, f, indent=2); f.write("\n")
PY
  say "pi: skills via $AGENTS_HOME/skills, prompts registered in $PI_SETTINGS"
else
  say "skipped pi wiring (--no-pi)"
fi

# 4. Advisory: check the optional browser-QA dependency (agent-browser). Never fatal.
echo "checking optional browser-QA deps (agent-browser)…"
bash "$REPO/scripts/doctor.sh" || say "qa/bench need agent-browser — see the hints above (install is optional)"

echo "tempest: done."
echo "  Restart your agent sessions so the new skills and commands load."
exit 0

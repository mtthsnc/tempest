#!/usr/bin/env bash
# ascension doctor — checks the optional browser-QA dependencies (agent-browser).
# Advisory and read-only: it diagnoses, it never installs or mutates settings.
# Exit 1 only if the core dependency (the agent-browser CLI) is missing, so it
# can gate a QA run; install.sh calls it non-fatally.
set -uo pipefail

ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }
info() { printf '  \033[36m·\033[0m %s\n' "$*"; }

PI_SETTINGS="${PI_HOME:-$HOME/.pi/agent}/settings.json"
missing_core=0

echo "ascension doctor — browser QA dependencies"

echo "== agent-browser CLI (required for qa / bench) =="
if command -v agent-browser >/dev/null 2>&1; then
  ver="$(agent-browser --version 2>/dev/null | head -1)"
  ok "agent-browser on PATH ($ver) — $(command -v agent-browser)"
else
  warn "agent-browser NOT on PATH"
  info "install it from https://github.com/vercel-labs/agent-browser (e.g. npm install -g agent-browser)"
  info "then ensure your npm global bin dir is on PATH"
  missing_core=1
fi

echo "== pi integration (optional — only if you use pi) =="
if command -v pi >/dev/null 2>&1; then
  ok "pi on PATH"
  if [ -f "$PI_SETTINGS" ] && grep -q "pi-agent-browser-native" "$PI_SETTINGS" 2>/dev/null; then
    ok "pi-agent-browser-native is registered in pi settings"
    info "deep check: run 'pi-agent-browser-doctor' for the wrapper's own diagnostics"
  else
    warn "pi-agent-browser-native not found in $PI_SETTINGS"
    info "install the native tool: pi install npm:pi-agent-browser-native"
  fi
else
  info "pi not found — skipping (fine if you only use Claude Code)"
fi

echo "== Claude Code integration (optional) =="
if command -v claude >/dev/null 2>&1; then
  ok "claude on PATH — the qa/bench skills drive the agent-browser CLI directly via the shell"
else
  info "claude not found — skipping"
fi

echo "== ffmpeg (optional — only for video 'record' capture) =="
if command -v ffmpeg >/dev/null 2>&1; then
  ok "ffmpeg on PATH"
else
  info "ffmpeg not found — screenshots/assertions still work; only video recording needs it"
fi

echo
if [ "$missing_core" -ne 0 ]; then
  echo "DOCTOR: agent-browser missing — qa and bench will not run until it is installed."
  exit 1
fi
echo "DOCTOR: ready — agent-browser is available."

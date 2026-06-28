# Changelog

All notable changes to ascension are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); versions follow semver.

## [Unreleased]

### Added
- Initial scaffold: cross-harness skill pack for Claude Code and pi.
- Claude marketplace + plugin manifests (`.claude-plugin/marketplace.json`,
  `plugins/ascension/.claude-plugin/plugin.json`) and a pi package manifest (`package.json` `pi` key).
- `install.sh` / `uninstall.sh`: idempotent wiring into `~/.agents/skills`, `~/.claude`, and pi's
  `settings.json` prompt paths.
- Conformance gate (`scripts/validate.sh`) and sandbox test suite (`tests/run.sh`); CI runs both.
- The sprint-loop spine as starter skills + commands, all passing the conformance gate:
  `office-hours` (reframe an idea), `plan` (reviewed plan), `build` (execute an increment),
  `review` (staff-level diff audit), `ship` (land a reviewed change).
- Browser-driven QA suite over [agent-browser](https://github.com/vercel-labs/agent-browser),
  harness-adaptive (pi's native `agent_browser` tool vs the `agent-browser` CLI on Claude Code):
  `qa` (UI acceptance/E2E with screenshot + assertion evidence), `verify` (run-and-observe),
  `bench` (Core Web Vitals / perf vs budget).
- `scripts/doctor.sh`: advisory, read-only check for the `agent-browser` CLI + pi wrapper; run
  non-fatally at the end of `install.sh`.
- `bcp` skill + `/bcp` command: bridges the stack to the Brand Context Protocol template at
  github.com/mtthsnc/bcp — scaffold a brand repo and route to its `brand-truth`/`landing-page`/
  `brand-check` skills, keeping the brand in its own owned repo.

### Planned
- `reflect` handoff to the separate reflect project; `autoplan` chaining; `cso`/`investigate` gates.
- OpenAI Codex and opencode install adapters.

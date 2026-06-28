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
- `plan` skill + `/plan` command — the first workflow (reviewed implementation plan), implemented
  end-to-end and verified to wire onto both harnesses.

### Planned
- `office-hours`, `build`, `review`, `test`, `ship` workflows.
- OpenAI Codex and opencode install adapters.

# AGENTS.md

Guidance for coding agents (and humans) working **on** the tempest repo. For what it does and how
to install it, see [README.md](README.md); for the cross-harness design, see
[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## What this repo is

tempest is a **software factory**: a set of opinionated build workflows — plan → build → review →
test → ship → reflect — shipped as **portable Agent Skills** that run identically on **Claude Code**
and **pi**. The skills are the product; the manifests and installer are thin wiring around one shared
source tree. It contains **no personal data**.

## Golden rules

1. **One source, two harnesses.** Every skill is authored once under
   `plugins/tempest/skills/<name>/SKILL.md` following the [Agent Skills standard](https://agentskills.io).
   Never fork a skill per harness. If a harness needs something different, express it in the install
   wiring, not in duplicated content.
2. **The conformance gate is law.** `./scripts/validate.sh` must pass before any commit;
   `./tests/run.sh` before any push. CI runs both.
3. **Skill `description` = trigger, not summary.** Start every skill description with "Use when…" and
   describe *when to invoke*, never the workflow. A description that summarizes the steps makes agents
   follow the summary instead of reading the skill body. (The gate enforces the "Use when" prefix.)
4. **Commands are portable or they don't ship.** A `commands/<verb>.md` must use only the arg subset
   both harnesses share (`$ARGUMENTS`, `$1`–`$9`) and carry a `description`. Pi-only (`${1:-def}`,
   `${@:N}`) and Claude-only (`allowed-tools`, `model`) syntax is flagged by the gate.
5. **No hardcoded user, home, or project paths.** Default to `~/.claude/…`, `~/.pi/…`, `~/.agents/…`
   (resolve per user) or read from settings. A grep for `/home/` in tracked files returns nothing.

## Layout

```
.claude-plugin/marketplace.json        Claude marketplace index (lists the plugin)
plugins/tempest/
  .claude-plugin/plugin.json           Claude plugin manifest
  skills/<name>/SKILL.md               THE skills (Agent Skills standard) — author once
  commands/<verb>.md                   thin slash entry points (also pi prompt templates)
package.json                           pi package manifest (pi.skills / pi.prompts)
AGENTS.md  CLAUDE.md -> AGENTS.md       instructions (Claude reads CLAUDE.md; pi reads either)
install.sh  uninstall.sh               idempotent wiring into ~/.agents, ~/.claude, ~/.pi
scripts/validate.sh                    conformance gate
tests/run.sh                           sandbox install + manifest/skill assertions
docs/ARCHITECTURE.md                   the cross-harness design
```

## Working here

- **Add/edit a skill:** create `plugins/tempest/skills/<name>/SKILL.md` with frontmatter `name`
  (== the directory name, lowercase letters/numbers/hyphens, ≤ 64) + `description` ("Use when…",
  ≤ 1024 chars). Structure the body as Overview → Procedure → Common mistakes → Guardrails. Add a thin
  `commands/<name>.md` if you want an explicit `/<name>` entry point. Run `./scripts/validate.sh`.
- **Add/edit a command:** `commands/<verb>.md` with a `description` and the portable arg subset.
- **Change install:** keep `install.sh` idempotent and re-run-safe; `./tests/run.sh` covers it.

## Why both harnesses just work

Both Claude Code and pi implement the Agent Skills `SKILL.md` standard (same `name`/`description`
frontmatter + progressive disclosure). pi reads `~/.agents/skills/` and `~/.claude/skills/` natively
and auto-exposes every skill as `/skill:<name>`. Slash commands map to pi prompt templates via the
shared arg subset. So one source tree installs to both with only thin manifest/symlink differences.
See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Commits & PRs

- Conventional-ish prefixes: `feat:`, `fix:`, `docs:`, `test:`, `chore:`.
- Update [CHANGELOG.md](CHANGELOG.md) under "Unreleased" for user-facing changes.
- Open PRs against `main`; CI must be green.

# Architecture

ascension is one source tree that installs to two agent harnesses (Claude Code and pi) with no
duplicated content. This document explains how that works and why it holds.

## The core bet: skills are portable

Claude Code and pi both implement the [Agent Skills standard](https://agentskills.io): a skill is a
directory with a `SKILL.md` whose frontmatter carries `name` and `description`, with progressive
disclosure (only the description is always in context; the body loads on demand when the task
matches). The frontmatter contract is the same on both. So **the skill is authored once** under
`plugins/ascension/skills/<name>/SKILL.md` and consumed natively by both.

## Mapping the three primitives

| Concept | Claude Code | pi | What we author |
|---|---|---|---|
| **Skill** | `~/.claude/skills/<name>/SKILL.md`; model-invoked | reads `~/.agents/skills/` and `~/.claude/skills/`; auto-exposes `/skill:<name>` | one `SKILL.md`, `name` == dir, `description` starts "Use when…" |
| **Command** | `~/.claude/commands/<verb>.md`, `$ARGUMENTS`/`$1` | prompt templates `~/.pi/agent/prompts/*.md`, `$ARGUMENTS`/`$1`/`$@`/`${1:-}` | `commands/<verb>.md` using the **shared subset** (`$ARGUMENTS`, `$1`–`$9`) |
| **Instructions** | `CLAUDE.md` (no native `AGENTS.md`) | `AGENTS.md` **or** `CLAUDE.md` | author `AGENTS.md`; `CLAUDE.md` is a symlink to it |

The command surface is the only place the two harnesses diverge in syntax, so the conformance gate
restricts command files to the portable subset and flags harness-specific syntax
(`${1:-default}`/`$@` are pi-only; `allowed-tools`/`model` frontmatter is Claude-only).

## Install topology

`install.sh` is idempotent and wires three locations (each overridable via `AGENTS_HOME`,
`CLAUDE_HOME`, `PI_HOME` env vars, which is what the test harness uses):

```
plugins/ascension/skills/<name>/  ──symlink──▶  ~/.agents/skills/<name>      (pi reads natively)
                                  ──symlink──▶  ~/.claude/skills/<name>      (Claude)
plugins/ascension/commands/<v>.md ──symlink──▶  ~/.claude/commands/<v>.md    (Claude)
plugins/ascension/commands/       ──register─▶  ~/.pi/agent/settings.json    (pi "prompts" path)
```

pi picks up skills through the neutral `~/.agents/skills/` location, so we don't register skills in
pi's settings (that would double-load and warn). pi prompt templates are not auto-discovered from
`~/.agents`, so the commands directory is registered explicitly in pi's `settings.json` `prompts`
array. `uninstall.sh` removes only the symlinks that resolve back into this repo and de-registers the
prompt path, so it is safe alongside other tools.

## Distribution

The same repo is both a Claude marketplace and a pi package:

- **Claude**: `.claude-plugin/marketplace.json` lists one plugin sourced at `./plugins/ascension`,
  whose `.claude-plugin/plugin.json` points `skills`/`commands` at its subdirectories.
- **pi**: top-level `package.json` carries a `pi` key (`pi.skills`, `pi.prompts`) pointing at the
  same `plugins/ascension/{skills,commands}` directories, and the `pi-package` keyword for the
  gallery. `pi install git:<repo>` consumes it.

No file is duplicated between the two distribution shapes; they reference the same source dirs.

## The conformance gate ("Brand Check")

`scripts/validate.sh` is the law (mirrored by `tests/run.sh` and CI). It enforces:

- shell syntax + shellcheck on every `*.sh`;
- valid JSON for `marketplace.json`, `plugin.json`, `package.json`;
- **manifest path integrity** — every path a manifest references actually exists;
- the **skill contract** — `name` lowercase/hyphen ≤ 64 and equal to its directory, `description`
  ≤ 1024 starting with "Use when…", frontmatter ≤ 1024;
- **command portability** — a `description` is present and only the shared arg subset is used;
- **no hardcoded home/user paths** in tracked files.

## Browser QA: one tool, two invocation paths

The `qa` and `bench` skills depend on [agent-browser](https://github.com/vercel-labs/agent-browser),
a standalone browser-automation CLI. The portability trick is the same as for skills: both harnesses
speak the **same agent-browser command vocabulary** (`open` → `snapshot -i` → `click @eN` → `assert`
→ `screenshot`; `vitals <url>` for perf), just invoked differently.

- **pi** uses the native `agent_browser` tool from the `pi-agent-browser-native` extension (input
  modes `args`/`job`/`qa`/`semanticAction`, plus `agent_browser_web_search`).
- **Claude Code** (or any harness without that tool) drives the `agent-browser` CLI directly via the
  shell.

So the skill body teaches the workflow once and says "prefer the native tool if present, else the
CLI." `agent-browser` is an **external dependency** (not bundled) and must be on PATH; on pi the
wrapper extension is also needed. `scripts/doctor.sh` is a read-only check for both, run non-fatally
by `install.sh`; it never installs or mutates settings.

## Why future harnesses are nearly free

OpenAI Codex and opencode also read `AGENTS.md` and consume the Agent Skills `SKILL.md` standard.
Adding them is mostly install wiring (where to symlink, which settings file to touch) plus, for
Codex, a `.codex-plugin/plugin.json` — the skills themselves are already portable. Out of scope for
v1, which targets pi + Claude Code only.

## Layout

| Path | Role |
|---|---|
| `plugins/ascension/skills/<name>/SKILL.md` | the workflows (authored once) |
| `plugins/ascension/commands/<verb>.md` | thin slash entry points (also pi prompt templates) |
| `.claude-plugin/marketplace.json` | Claude marketplace index |
| `plugins/ascension/.claude-plugin/plugin.json` | Claude plugin manifest |
| `package.json` | pi package manifest (`pi.skills` / `pi.prompts`) |
| `AGENTS.md` / `CLAUDE.md` → `AGENTS.md` | instructions for working on the repo |
| `install.sh` / `uninstall.sh` | idempotent cross-harness wiring |
| `scripts/validate.sh` | conformance gate |
| `tests/run.sh` | sandbox install + wiring assertions |

# ascension

A **software factory** for AI coding agents — opinionated build workflows shipped as portable
[Agent Skills](https://agentskills.io) that run **identically on [Claude Code](https://claude.com/claude-code)
and [pi](https://pi.dev)**.

Inspired by [gstack](https://github.com/garrytan/gstack): a sprint loop —
**plan → build → review → test → ship → reflect** — encoded as skills your agent loads on demand.
One source tree, two harnesses, no per-tool forks.

> Status: **v0.1 — early.** The `plan` workflow is implemented end-to-end; the rest of the spine is
> on the roadmap. The conformance gate is green.

## Why it's portable

Both Claude Code and pi implement the same Agent Skills `SKILL.md` standard (`name` + `description`
frontmatter, progressive disclosure). pi reads `~/.agents/skills/` and `~/.claude/skills/` natively
and exposes every skill as `/skill:<name>`; slash commands map to pi prompt templates through a
shared argument subset. So a single `plugins/ascension/skills/` tree installs to both with only thin
manifest/symlink differences. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Install

### Quick (both harnesses, symlink-based)

```bash
git clone https://github.com/mtthsnc/ascension.git
cd ascension
./install.sh            # or --no-claude / --no-pi to install one
```

This symlinks skills into `~/.agents/skills/` (read by pi) and `~/.claude/skills/`, symlinks commands
into `~/.claude/commands/`, and registers the commands directory as a pi prompt-template path in
`~/.pi/agent/settings.json`. Re-run after `git pull`; it is idempotent. Remove with `./uninstall.sh`.

### Claude Code via the plugin marketplace

```text
/plugin marketplace add mtthsnc/ascension
/plugin install ascension@ascension
```

### pi as a package

```bash
pi install git:github.com/mtthsnc/ascension
```

Restart your agent sessions after installing so the skills and commands load.

## Use

| Workflow | Skill | Command | Status |
|---|---|---|---|
| Reviewed implementation plan | `plan` | `/plan <task>` | ✅ implemented |
| Reframe an idea before building | `office-hours` | `/office-hours` | ⏳ planned |
| Execute a plan increment | `build` | `/build` | ⏳ planned |
| Staff-level diff review | `review` | `/review` | ⏳ planned |
| Real-run verification | `test` | `/test` | ⏳ planned |
| PR + release hygiene | `ship` | `/ship` | ⏳ planned |

In Claude Code, type `/plan <task>` or let the agent auto-invoke the `plan` skill. In pi, type
`/plan <task>` or `/skill:plan <task>`.

## Develop

The skills are the product; everything else is thin wiring. See [AGENTS.md](AGENTS.md) for the
golden rules and [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the design. Before committing:

```bash
./scripts/validate.sh   # conformance gate (the "Brand Check")
./tests/run.sh          # sandbox install + wiring assertions
```

## License

MIT © mtthsnc. See [LICENSE](LICENSE).

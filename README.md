# Tempest

A **software factory** for AI coding agents — opinionated build workflows shipped as portable
[Agent Skills](https://agentskills.io) that run **identically on [Claude Code](https://claude.com/claude-code)
and [pi](https://pi.dev)**.

A sprint loop — **office-hours → plan → build → review → ship**, plus browser-driven QA — encoded as
skills your agent loads on demand. One source tree, two harnesses, no per-tool forks.

> Status: **v0.1.** The full sprint-loop spine, the QA suite (`qa`/`verify`/`bench`), and the `bcp`
> brand bridge are implemented; the conformance gate and tests are green.

## Why it's portable

Both Claude Code and pi implement the same Agent Skills `SKILL.md` standard (`name` + `description`
frontmatter, progressive disclosure). pi reads `~/.agents/skills/` and `~/.claude/skills/` natively
and exposes every skill as `/skill:<name>`; slash commands map to pi prompt templates through a
shared argument subset. So a single `plugins/tempest/skills/` tree installs to both with only thin
manifest/symlink differences. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Install

### Quick (both harnesses, symlink-based)

```bash
git clone https://github.com/mtthsnc/tempest.git
cd tempest
./install.sh            # or --no-claude / --no-pi to install one
```

This symlinks skills into `~/.agents/skills/` (read by pi) and `~/.claude/skills/`, symlinks commands
into `~/.claude/commands/`, and registers the commands directory as a pi prompt-template path in
`~/.pi/agent/settings.json`. Re-run after `git pull`; it is idempotent. Remove with `./uninstall.sh`.

### Claude Code via the plugin marketplace

```text
/plugin marketplace add mtthsnc/tempest
/plugin install tempest@tempest
```

### pi as a package

```bash
pi install git:github.com/mtthsnc/tempest
```

Restart your agent sessions after installing so the skills and commands load.

## Use

The sprint loop — **office-hours → plan → build → review → ship** (with `reflect` handled by the
separate [reflect](https://github.com/mtthsnc/reflect) project):

| Workflow | Skill | Command | Status |
|---|---|---|---|
| Reframe a raw idea with forcing questions | `office-hours` | `/office-hours <idea>` | ✅ implemented |
| Reviewed implementation plan | `plan` | `/plan <task>` | ✅ implemented |
| Execute an approved plan increment | `build` | `/build <increment>` | ✅ implemented |
| Staff-level diff review (optional auto-fix) | `review` | `/review <diff/PR>` | ✅ implemented |
| Land a reviewed change (PR, CI, deploy) | `ship` | `/ship <what>` | ✅ implemented |

Each ships as a deliberately generic **starter** skill — a spine you customize with your own
standards. In Claude Code, type `/plan <task>` or let the agent auto-invoke the skill.
In pi, type `/plan <task>` or `/skill:plan <task>`.

### Quality & QA (browser-driven)

| Workflow | Skill | Command | What it does |
|---|---|---|---|
| Browser UI acceptance / E2E / smoke | `qa` | `/qa <flow/URL>` | Drives the real UI, asserts, captures screenshot evidence |
| Run-and-observe verification | `verify` | `/verify <change>` | Runs the app and confirms real behavior (hands UI off to `qa`) |
| Performance / Core Web Vitals | `bench` | `/bench <URL>` | Measures LCP/CLS/INP vs a budget or baseline |

`qa` and `bench` are powered by **[agent-browser](https://github.com/vercel-labs/agent-browser)** — a
browser-automation CLI. The skills are **harness-adaptive over the same command vocabulary**: on pi
they use the native `agent_browser` tool ([pi-agent-browser-native](https://github.com/fitchmultz/pi-agent-browser-native)),
and on Claude Code they drive the `agent-browser` CLI directly via the shell.

**Dependency:** install the `agent-browser` CLI and keep it on PATH (see its
[install docs](https://github.com/vercel-labs/agent-browser)); on pi also run
`pi install npm:pi-agent-browser-native`. Then `./scripts/doctor.sh` verifies the setup (it's also
run, non-fatally, at the end of `./install.sh`).

### Brand (BCP)

| Workflow | Skill | Command | What it does |
|---|---|---|---|
| Brand Context Protocol | `bcp` | `/bcp [scaffold \| <task>]` | Scaffold/operate a brand: capture truth, produce on-brand output, score it |

`bcp` bridges the dev stack to **[BCP](https://github.com/mtthsnc/bcp)** — a git-native Brand Context
Protocol where a brand is cited, dated truth that humans and agents build from. The skill scaffolds
the BCP template into a project and routes to its own skills (`brand-truth`, `landing-page`,
`brand-check`); the brand lives in its own owned repo, not locked inside this tooling.

## Develop

The skills are the product; everything else is thin wiring. See [AGENTS.md](AGENTS.md) for the
golden rules and [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the design. Before committing:

```bash
./scripts/validate.sh   # conformance gate (the "Brand Check")
./tests/run.sh          # sandbox install + wiring assertions
```

## License

MIT © mtthsnc. See [LICENSE](LICENSE).

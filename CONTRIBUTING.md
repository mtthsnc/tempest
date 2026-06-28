# Contributing to tempest

Thanks for helping build the factory. The skills are the product; everything else is thin wiring.

## Setup

```bash
pip install pre-commit            # plus shellcheck (apt-get install shellcheck or a release binary)
pre-commit install && pre-commit install --hook-type pre-push
./scripts/validate.sh && ./tests/run.sh
```

## Adding or editing a skill

1. Create `plugins/tempest/skills/<name>/SKILL.md` with frontmatter:
   - `name` — the directory name, lowercase letters/numbers/hyphens, ≤ 64 chars.
   - `description` — starts with **"Use when…"**, describes *when to invoke* (not the steps), ≤ 1024.
2. Structure the body: **Overview → Procedure → Common mistakes → Guardrails**.
3. Add a thin `commands/<name>.md` if you want an explicit `/<name>` entry point. Use only the
   portable arg subset (`$ARGUMENTS`, `$1`–`$9`) and include a `description`.
4. Run `./scripts/validate.sh`.

## Golden rules

See [AGENTS.md](AGENTS.md). In short: one source for both harnesses, the gate is law, skill
descriptions are triggers not summaries, commands stay portable, and no hardcoded home paths.

## Commits & PRs

- Conventional-ish prefixes: `feat:`, `fix:`, `docs:`, `test:`, `chore:`.
- Update [CHANGELOG.md](CHANGELOG.md) under "Unreleased" for user-facing changes.
- Open PRs against `main`; CI (conformance + tests) must be green.

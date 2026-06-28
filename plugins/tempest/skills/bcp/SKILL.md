---
name: bcp
description: Use when brand or marketing work needs to be on-brand and traceable — set up a Brand Context Protocol (BCP) for a business, capture brand truth, or produce/score a deliverable (landing page, deck, email, ad copy) against the brand. Triggers on "set up a brand", "make this on-brand", "scaffold a BCP", "brand context protocol", "produce on-brand <thing>", "is this on-brand". Bridges the dev stack to the BCP template at github.com/mtthsnc/bcp.
---

# bcp — bring a Brand Context Protocol into the work

## Overview

The bridge from this software factory to **BCP** (Brand Context Protocol) — a git-native standard
where a brand is written down as cited, dated **truth** that humans and AI agents build from, so
output is on-brand by construction and carries a trace. BCP lives in its own repo
(`github.com/mtthsnc/bcp`); this skill scaffolds it into a project and drives its skills. It does not
reimplement BCP — **the brand repo is the source of truth**, owned by you, not locked in tooling.

This is a STARTER skill — a generic spine. Rewrite the scaffold source and the per-deliverable flow
to match how your business runs.

## Procedure

### 1. Find or create the brand
- Look for an existing BCP in the project: a `harness/brand/` tree (optionally with `harness/config.json`).
- If none exists and brand work is needed, **scaffold** one: fetch the template into a brand repo,
  e.g. `git clone --depth 1 https://github.com/mtthsnc/bcp <brand-dir>` (or `npx degit mtthsnc/bcp <brand-dir>`),
  set `brand.name` in `harness/config.json`, and run its `./install.sh` to wire the BCP skills for pi
  and Claude Code. Work from the brand repo root so its `AGENTS.md`/`CLAUDE.md` and skills load.

### 2. Capture or extend Brand Truth
- Drive BCP's `brand-truth` skill: turn raw input (interviews, audit, existing assets) into cited,
  dated truths in `harness/brand/` — positioning (`01-imprint`), voice + **refusals** (`02-voice`),
  design tokens (`03-design`), lenses, architecture. Append-only; supersede, never overwrite.

### 3. Produce a deliverable
- Use a BCP contract skill (e.g. `landing-page`) to generate the asset into `harness/output/<slug>/`
  with a `trace.md` citing the truth ids it used. Draw only from Brand Truth — if a fact is missing,
  add it via `brand-truth` first rather than inventing it.

### 4. Check before shipping
- Run BCP's `brand-check` skill to score the output against the brand (cited violations, written back
  to the trace, logged to `09-loops`), and run `./scripts/brand-check.sh` for the structural gate.
- Recurring conflicts become proposed new truths/refusals + a dated decision — human-approved.

## Common mistakes
- **Brand work with no BCP.** Producing copy/design without a source of truth yields off-brand,
  untraceable output. Scaffold or locate the brand repo first.
- **Inventing brand facts here.** This skill orchestrates; it does not author truths. Missing facts
  go into Brand Truth via `brand-truth`, with a source.
- **Shipping without a trace or a check.** Every deliverable carries a trace and passes `brand-check`.
- **Editing truths in place.** BCP is append-only — supersede, don't overwrite.

## Guardrails
- The BCP repo is the source of truth; do not duplicate or override brand facts inside this stack.
- Every brand deliverable must carry a trace and pass `brand-check` before it's called done.
- Keep the brand in its own git repo — owned and portable, not rented inside someone's tool.
- Defer brand authoring, scoring, and production to BCP's own skills (`brand-truth`, `landing-page`,
  `brand-check`); this skill only routes to them.

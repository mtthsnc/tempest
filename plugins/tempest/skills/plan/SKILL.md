---
name: plan
description: Use when a coding task is non-trivial — a new feature, a multi-file change, a refactor, or anything with more than one reasonable approach — and you want a reviewed implementation plan before writing code. Produces a concrete, criticised plan you can hand to a build step. Skip for typo-level or single-obvious-line fixes.
---

# plan — produce a reviewed implementation plan

## Overview

The front of the factory. Turn a task into a plan that is concrete enough to execute and honest
about its risks — *before* any code is written. A good plan names the files it will touch, reuses
what already exists, and has survived its own strongest objection.

This is a STARTER skill — a generic spine. Rewrite the procedure and the review lenses below to
encode your own engineering opinions and standards.

The plan is the output. You do not implement here; you produce a plan a `build` step can follow.

## Procedure

### 1. Understand before proposing
- Restate the task in one sentence. If that sentence is ambiguous, ask the user **now** — a wrong
  assumption is cheapest to fix here.
- Explore the codebase for existing functions, utilities, and patterns that already do part of this.
  Prefer reusing them over writing new code. Note the concrete file paths.
- Identify the smallest change that fully satisfies the task.

### 2. Draft the plan
Write a plan with these parts:
- **Context** — why this change, what problem it solves, the intended outcome.
- **Approach** — the recommended approach only (not a survey). Name the trade-off you accepted.
- **Changes** — the files to create/modify, each with a one-line description of what changes. For a
  pattern repeated across many files, describe it once and list a few representative paths.
- **Reuse** — existing functions/utilities (with paths) the build should call instead of reinventing.
- **Verification** — how to prove it works end-to-end: the command to run, the test to add, the
  behavior to observe.
- **Risks / unknowns** — what could go wrong and what you are unsure about.

### 3. Review it against itself
Before presenting, attack your own plan from these lenses (collapse or extend to taste):
- **Correctness** — does it actually satisfy the restated task? Any missed case?
- **Scope** — is anything in here not required? Cut it. Is anything required missing? Add it.
- **Simplicity / reuse** — is there an existing pattern that makes a chunk of this unnecessary?
- **Reversibility** — if this is wrong, how hard is it to undo? Prefer the more reversible path.

Fold the answers back into the plan. State explicitly what the review changed.

### 4. Present and get sign-off
Present the revised plan. Ask the user to approve or adjust before any implementation begins.

## Common mistakes
- **Planning before understanding.** Exploring the code after drafting leads to plans that fight the
  codebase. Read first.
- **Surveying instead of recommending.** Pick an approach and defend it; don't hand the user a menu.
- **Reinventing what exists.** If a utility already does it, the plan should call it, not re-create it.
- **Skipping the self-review.** An unreviewed plan is a draft. The review is what makes this a plan.
- **Implementing inside the plan step.** Stop at the plan. Build is a separate step.

## Guardrails
- No code changes in this skill — produce a plan only.
- Always name concrete file paths; a plan with no paths is a wish.
- Surface unknowns rather than papering over them; a flagged risk is cheaper than a silent one.
- Get explicit sign-off before handing the plan to a build step.

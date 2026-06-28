---
name: build
description: Use when you have an approved plan or a defined increment and are ready to write the code — implementing a feature, refactor, or fix that someone has already scoped and signed off. Executes the plan with discipline: follow existing patterns, keep changes reviewable, commit atomically, verify as you go. Skip when there is no agreed plan yet — plan first.
---

# build — execute an approved plan with discipline

## Overview

The floor of the factory. Take an approved plan and turn it into working, committed code — without
drifting from what was agreed. A good build follows the patterns already in the codebase, lands in
small reviewable commits, and proves each step works before moving on.

This is a STARTER skill — a generic spine. Rewrite the procedure and guardrails below to encode your
own engineering standards: your commit conventions, your verification commands, your patterns.

The plan is the input. You implement it here; you do not re-design it.

## Procedure

### 1. Confirm the increment and its definition of done
- Restate what you are building in one sentence, and the plan's verification — the command, test, or
  observable behavior that proves it done.
- If the plan is missing or vague on done-ness, stop and get it clarified before writing code.

### 2. Pick the smallest shippable increment
- Work one logical slice, not the whole plan at once. The increment should compile, pass, and be
  reviewable on its own.
- If the plan is large, sequence the slices and build them one at a time.

### 3. Implement in the codebase's idiom
- Match the surrounding naming, structure, and style. Reuse the functions and utilities the plan
  named instead of inventing new ones.
- Make the change, nothing more. Resist the unrelated cleanup.

### 4. Verify as you go
- Run the plan's verification — tests, typecheck, lint — after each slice, not only at the end.
- Keep the tree green: never leave it in a broken state between slices.

### 5. Commit atomically
- One commit per logical change, with a clear message describing what and why. The diff should be
  small enough to review in one sitting.
- Never commit with failing tests.

### 6. Stop cleanly at the boundary
- When the increment is done and verified, stop. Report what landed, what's verified, and what of
  the plan remains.

## Common mistakes
- **Scope creep.** Building beyond the plan because it's "right there." Anything not in the plan is a
  separate increment — note it, don't sneak it in.
- **Big-bang commits.** One giant diff nobody can review. Commit per logical change instead.
- **Inventing new patterns.** Introducing a new abstraction when an existing one fits. Match what's
  there.
- **Deferring all verification to the end.** Bugs found late are expensive. Verify each slice.
- **Leaving the tree broken.** A half-applied change between commits blocks everyone. Land slices
  that stand on their own.

## Guardrails
- Stay within the approved plan. If reality diverges from it, stop and re-plan rather than improvising.
- Never commit with failing tests, and never leave the tree in a broken state.
- Keep each commit small and reviewable — one logical change, clear message.
- Reuse before you write; match the codebase's existing patterns and style.

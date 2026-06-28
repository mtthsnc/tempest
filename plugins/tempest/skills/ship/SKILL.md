---
name: ship
description: Use when a change has been reviewed and you are ready to land it — merge the PR, cut the release, or push to production. Drives the change out the door: tests in place, changelog updated, a tight PR description, CI green, and the deploy verified end-to-end. Skip while still building or before review; this is the last mile, not the work itself.
---

# ship — land a reviewed change cleanly

## Overview

The loading dock. Take a change that has already been reviewed and get it out the door without
surprises: tests in place, changelog updated, an honest PR description, CI green, and the deploy
actually verified — not just assumed. Shipping is outward-facing and often irreversible, so the bar
is "proven in the world," not "merged."

This is a STARTER skill — a generic spine. Rewrite the procedure below to encode your own release
process: your CI provider, your changelog format, your deploy and rollback commands.

You do not build or re-review here. The change is done; your job is to land it safely.

## Procedure

### 1. Confirm it's ready to ship
- Verify the change has been reviewed and the working tree is clean — no stray edits, no debug code.
- Confirm the diff is one coherent change. If unrelated work has crept in, split it out; ship one
  thing at a time.

### 2. Tests and changelog
- Ensure tests cover the change and the full suite passes locally. A green local run is the floor.
- Add a changelog entry for any user-facing change — what changed, in the user's words.

### 3. Write a tight PR description
- **What** changed, in one or two sentences.
- **Why** — the problem it solves or the reason it's worth shipping.
- **How verified** — the exact tests run and behavior observed. Name the risk honestly; don't bury it.

### 4. Open the PR (or land) and wait for CI
- Push and open the PR (or land, per your flow). Watch CI to completion.
- If CI is red or skipped, stop and fix the cause — never override or merge around it.

### 5. Verify the deploy end-to-end
- After merge/release, confirm the deploy itself works: hit the running service, check the version,
  observe the new behavior in the real environment. CI passing is not the deploy working.
- If it's broken, roll back first, diagnose second.

### 6. Record what shipped
- Note the version/PR/commit and what it delivered. Close the loop with whoever was waiting on it.

## Common mistakes
- **Shipping on red or skipped CI.** A merge that bypasses a failing gate is a future incident.
- **No changelog entry.** User-facing changes that aren't recorded are changes nobody can find later.
- **A vague PR body.** "Misc fixes" hides the risk. Say what changed and how you know it works.
- **Declaring done at green CI.** CI passed ≠ deploy works. Verify the running thing.
- **Bundling unrelated changes.** One release, one concern — so a rollback is surgical, not total.

## Guardrails
- Never land on red CI. Fix the gate, don't bypass it.
- Require a changelog entry for every user-facing change.
- Verify the deploy in the real environment before calling it shipped.
- For anything irreversible or outward-facing — a release, a production push — confirm with the human
  before the point of no return.

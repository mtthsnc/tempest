---
name: burst
description: Use when rapidly shipping a small, well-understood change end-to-end — a one-liner fix or small well-scoped feature where writing a plan would be pure overhead. Drives issue creation, an isolated branch, implementation, browser-driven validation (via `qa`), a squashed commit, and a PR in one uninterrupted pass after a single up-front confirmation. Skip for anything with unclear scope, real design tradeoffs, or risk — route those through office-hours/plan/build/review instead.
---

# burst — ship a small, well-understood change in one shot

## Overview

The fast lane. Most changes deserve the full sprint loop — office-hours, a written plan, a reviewed
build. Some don't: a well-scoped one-liner, a copy fix, a small feature where the "plan" is obvious
enough that writing it down is pure overhead. Burst is that fast lane — issue, branch, implement,
validate, squash, PR — in one uninterrupted pass, with exactly one checkpoint: a plan confirmation up
front. If the scope turns out to be unclear or risky once you're sniffing the codebase, stop and route
to `plan` instead; burst is for speed on genuinely small changes, not for skipping planning on big ones.

This is a STARTER skill — a generic spine. The procedure below encodes a GitHub + `gh` CLI flow with
a fork/upstream remote split; rewrite it for your own VCS host, issue tracker, and project/label
conventions (marked below with **customize this**).

## Procedure

### 1. Confirm prerequisites
- Requires an `upstream` remote (`git remote -v`) and an authenticated VCS CLI (e.g. `gh auth
  status`). If either is missing, stop and tell the user what to add — burst does not set these up
  for you.

### 2. Sniff the codebase (10 seconds, not ten minutes)
- Identify the `upstream` (org) and `origin` (fork) remotes and the upstream default branch.
- Scan for the files the change will likely touch. Classify the change as `fix` or `feat` and pick a
  conventional-commit scope.
- **Customize this:** look up any repo-specific labels/issue-types/project boards you plan to apply
  in step 4.

### 3. Confirm the plan — the only checkpoint
- Present type, scope, issue title, and files likely touched. Wait for approval.
- If declined, adjust and re-confirm. Once approved, run the rest without interruption — no further
  questions, no re-litigating scope.

### 4. Create the issue upstream
- File the issue on the upstream repo (never the fork), with a Bug/Root-Cause/Fix or
  Problem/Solution body depending on type. Assign it to yourself.
- **Customize this:** setting an issue type, adding to a project board, or applying labels are your
  org's conventions — wire them here if you use them.

### 5. Create an isolated workspace
- Branch off the upstream default branch, not your current branch. Name it deterministically from the
  issue (e.g. `issue-<N>`) so it's traceable — pick one convention and never deviate.
- Use a native worktree tool if your harness has one; otherwise `git worktree add` directly. Never
  implement on your main checkout.

### 6. Implement
- Code the change directly — no sub-plan, no TDD detour, no scope creep. If step 2 flagged this as a
  frontend/UI change, capture a baseline screenshot of the current behavior now, before editing
  anything — it's the only point in the pipeline where the "before" state still exists.
- Do not add tests unless the user's brief explicitly asked for them. Burst ships the described
  change — nothing more, nothing less.

### 7. Validate before squashing (frontend/UI changes)
- Skip this step for non-UI changes. Otherwise, hand off to the `qa` skill to drive the real UI
  end-to-end (golden path, edge cases, a11y basics, no new console errors) and capture an "after"
  screenshot at the same view as step 6's baseline. Don't reimplement browser automation here — `qa`
  already owns that and is harness-adaptive; burst calling it directly would only work on one harness.
- **On failure:** fix and re-run `qa`. Diagnose the actual root cause after the first failed attempt
  instead of guessing again blind. Cap real attempts at 3.
- **Still broken after 3 attempts:** an edge-case bug gets scoped out of this change — ship the safe
  subset, file a follow-up issue describing what was tried. A core-ask bug means stop the pipeline and
  report to the user. Either way: never ship a known regression silently, never take a 4th swing.

### 8. Squash and push
- Squash to one commit with a conventional-commit message that closes the issue. Use a
  non-interactive squash mechanism (e.g. `git reset --soft` then commit) — interactive rebase is a
  bad fit for unattended execution. Push to your fork, force-with-lease if the branch already exists
  remotely.

### 9. Open the PR upstream
- Title matches the commit. Lead the body with before/after evidence if step 7 produced it, then a
  short summary and a test-plan checklist reflecting what was *actually* verified — not generic
  placeholders. Close the issue in the body.
- Never assign the PR to yourself — only the issue gets assigned.
- Report both URLs (issue + PR) back to the user. Always both, every time.

## Common mistakes
- **Treating "burst" as permission to skip judgment.** If sniffing the codebase reveals the change is
  bigger or riskier than it looked, stop and route to `plan` — burst is for genuinely small changes,
  not a shortcut around planning big ones.
- **Re-litigating scope after the step-3 approval.** One checkpoint means one checkpoint. Asking more
  questions or re-confirming mid-flight defeats the point of burst.
- **Reimplementing browser QA inline.** Step 7 hands off to `qa` on purpose — it's already
  harness-adaptive (native tool on pi, CLI elsewhere); duplicating that logic here breaks portability.
- **Shipping a known bug because time is short.** A regression found in step 7 still needs the
  scope-down-or-stop decision. "It's minor" is not a reason to skip it.
- **Guessing at a fix repeatedly instead of diagnosing.** After one failed validation attempt, find
  the actual root cause before trying again — don't spend all 3 attempts on variations of the same
  blind guess.
- **Working on the main checkout.** Always branch through an isolated workspace (step 5); never
  implement directly on the branch you started on.

## Guardrails
- Never skip the step-3 confirmation, and never add a second one — it is the only gate.
- Issues live upstream, never on the fork.
- Only the issue is assigned to you; the PR is not.
- Branch naming is deterministic from the issue number — pick one convention, apply it every time.
- Cap validation-fix attempts at 3; beyond that, scope down or stop — never loop indefinitely and
  never ship a known regression unremarked.
- Always report both the issue URL and the PR URL when done.

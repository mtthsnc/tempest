---
name: review
description: Use when you have a diff, a PR, or a set of changed files and want a staff-engineer-level audit before it merges — correctness and security bugs, error handling, and simplification/reuse opportunities — with findings classified by severity and confidence and high-confidence fixes optionally applied and verified. Skip for trivial typo-level changes.
---

# review — audit a diff like a staff engineer

## Overview

The quality gate. Read a change the way a careful senior reviewer would: hunt for real bugs and
security holes first, then for ways the code could be simpler or reuse what already exists. Every
finding gets a location, a concrete fix, and an honest confidence level — and the high-confidence,
low-risk ones can be fixed and verified on the spot.

This is a STARTER skill — a generic spine. Rewrite the review lenses and the severity bar below to
encode your own engineering opinions and standards.

The output is a grouped set of findings (must-fix vs. nits), optionally with applied-and-verified
fixes. You review the change; you do not redesign it.

## Procedure

### 1. Scope the diff
- Establish exactly what changed and against what base (e.g. `git diff <base>...HEAD`, a PR, or the
  named files). If the base is ambiguous, ask before reviewing the wrong thing.
- Restate in one sentence what the change is *supposed* to do. Review whether it does that — not just
  whether the code that's there is locally fine.
- Read enough surrounding code to judge each change in context, not in isolation.

### 2. Review through distinct lenses
Pass over the diff once per lens (collapse or extend to taste):
- **Correctness / logic** — off-by-one, null/empty/error paths, boundary and concurrency cases, wrong
  conditionals, broken invariants. Does it handle the inputs it will actually see?
- **Security** — untrusted input, injection, authz/authn gaps, secrets, unsafe deserialization.
- **Error handling** — swallowed errors, missing cleanup, failure modes left unhandled.
- **Simplification / reuse** — is there an existing utility or pattern that makes a chunk of this
  unnecessary? Can it be smaller, clearer, or less duplicated?
- **Tests / coverage** — are the new paths and edge cases tested? What's the gap?

### 3. Classify each finding
Tag every finding with:
- **Severity** — must-fix (bug, security, data loss) vs. nit (style, taste).
- **Confidence** — high (you can prove it) vs. a judgement call for the human.
Give each finding a `file:line` reference and a concrete suggested fix. A finding with no location or
no fix is noise — drop it.

### 4. Optionally apply high-confidence fixes
For findings that are **high-confidence AND low-risk** only:
- Apply the fix.
- **Verify it**: re-read the result, run the tests / build / linter. Never present an unverified fix.
- Leave every judgement call and every uncertain finding for the human — do not auto-fix those.

### 5. Present findings grouped
Lead with **must-fix**, then **nits**, then **applied fixes** (with how you verified each). Cite
`file:line` throughout. Keep the signal high: a short list of real problems beats a long list of
opinions.

## Common mistakes
- **Drowning real bugs in style nitpicks.** A wall of taste comments buries the one finding that
  matters. Lead with correctness and security; gate the nits.
- **Flagging without a fix or a location.** "This feels off" is not a finding. Give `file:line` and a
  concrete change.
- **Auto-fixing without verifying.** An applied fix you didn't re-read and re-test is a new bug.
- **Reviewing the code instead of the task.** Code can be locally clean and still not solve the
  problem. Check the change against what it was meant to do.

## Guardrails
- Prioritise correctness and security over style — always.
- Only auto-fix high-confidence, low-risk findings; leave judgement calls for the human.
- Never apply a fix you haven't verified by re-reading and re-running the relevant checks.
- Cite `file:line` for every finding; a finding with no location does not ship.

---
description: Ship a small, well-understood change end-to-end in one uninterrupted pass
argument-hint: [change to ship]
---
Load and follow the `burst` skill to ship this change fast.

What to ship: $ARGUMENTS

Sniff the codebase, present the plan, and wait for approval — that is the only checkpoint. Once
approved, create the issue upstream, work in an isolated branch, implement, hand off to `qa` for
browser validation if it's a UI change, squash to one commit, and open the PR. Report both the issue
URL and the PR URL when done. If the change turns out bigger or riskier than it looked, stop and
route to `plan` instead.

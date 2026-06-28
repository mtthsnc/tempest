---
description: Verify a change works through the real browser UI with screenshot and assertion evidence
argument-hint: [what to QA / URL / flow]
---
Load and follow the `qa` skill to verify the change through the real browser UI via agent-browser.

What to QA: $ARGUMENTS

Work through the skill's procedure end to end: open the page, snapshot the interactive tree,
interact using current refs, assert the observable outcome, and save a screenshot. Report PASS only
on verified evidence; on failure, capture a repro and add a regression test. Prefer the native
`agent_browser` tool if available, otherwise drive the `agent-browser` CLI via the shell.

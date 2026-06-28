---
description: Verify a change works by running the app and observing real behavior
argument-hint: [change / feature to verify]
---
Load and follow the `verify` skill to confirm the change actually works by running it.

Change to verify: $ARGUMENTS

Work through the skill's procedure end to end: pin down the observable behavior, find the project's
way to run it, drive the real scenario (hand off to the `qa` skill for web-UI behavior), then judge
PASS/FAIL on concrete observed evidence and report it.

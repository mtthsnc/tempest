---
name: verify
description: Use when you need to confirm a code change actually works by running the app and observing real behavior — not by trusting green unit tests. Triggers — verify a PR or fix, confirm a feature works, manually validate a change before shipping, start the app/server/CLI and exercise the specific behavior the change targets, judge PASS/FAIL on observed evidence. For web-UI behavior, hand off to the `qa` skill.
---

# verify — run it and judge on what you observe

## Overview

Proof by observation. A change is verified only when you have *run* the thing, exercised the exact
behavior the change targets, and seen real evidence that it does what it should. Tests passing is a
signal, not proof — verification is watching the feature work for the user.

This is a STARTER skill — a generic spine. Rewrite the procedure below to encode how *your* project
is actually run and what counts as convincing evidence.

You verify here; you do not fix or re-review. If it fails, report the failure with evidence.

## Procedure

### 1. Pin down the behavior
- Restate, in concrete observable terms, what the change is supposed to make happen — the specific
  input, action, or condition and the result you'd expect to see.
- If you can't name an observable difference, you can't verify it. Get that crisp first.

### 2. Figure out how to run it
- Find this project's documented build/run/start command — dev server, CLI entry point, script, or
  test harness. Read the README, package manifest, or task runner; use the project's own way.
- Note how you'll observe output: stdout, logs, HTTP responses, exit codes, files produced, UI.

### 3. Run it and drive the real scenario
- Start it and exercise the actual code path the change touches, with real inputs.
- For web-UI behavior, hand off to the `qa` skill — it drives a real browser via agent-browser.
  Don't guess at rendered UI from the code.
- Otherwise observe directly: read the CLI output, tail the logs, hit the endpoint, check the file.

### 4. Judge against expected behavior
- Capture concrete evidence — an output snippet, a log line, a status code, a screenshot.
- Decide PASS or FAIL against the expectation from step 1. Note anything surprising, and scan the
  run output for warnings or errors even if the headline result looked right.

### 5. Report
- State PASS/FAIL, exactly what you ran, what you observed (with the evidence), and any follow-up.

## Common mistakes
- **Treating green unit tests as proof.** Tests check code in isolation; verification checks the
  feature works for the user. Run the actual thing.
- **Never running it.** Reading the diff and concluding it "should work" is not verification.
- **"Looks good" with no evidence.** Every PASS/FAIL needs a concrete observation behind it.
- **Verifying the wrong path.** Exercise the path the change touched, not an adjacent one.
- **Ignoring warnings/errors in the output.** A passing result over a stack trace is not a pass.

## Guardrails
- You must actually RUN it — reasoning about the code is never verification.
- Cite concrete observed evidence for the PASS/FAIL call.
- For browser/UI behavior defer to the `qa` skill rather than guessing at the rendering.
- Don't declare success on partial or unrelated output; verify the specific targeted behavior.

---
name: qa
description: Use when you must verify a change actually works through the REAL browser UI — acceptance, end-to-end, smoke tests, form interactions, navigation, login flows — driven by the agent-browser tool. Invoke when "click through it", "does the UI work", "smoke test the page", or browser-level evidence (screenshots, assertions) is wanted, not just unit tests. Produces PASS/FAIL backed by a verified assertion and a saved screenshot.
---

# qa — browser-driven UI acceptance via agent-browser

## Overview

Prove the feature works the way a user would hit it — in a real browser. This skill drives
`agent-browser` to open pages, read the live accessibility tree, interact with real elements, and
assert observable state, then reports PASS/FAIL backed by a screenshot and a held assertion.

This is a STARTER skill — a generic spine. Rewrite the procedure, the flows you smoke-test, and the
stop boundaries below to encode your own product's critical paths and acceptance bar.

This skill is harness-adaptive over the same `agent-browser` command vocabulary:
- **On pi:** prefer the native `agent_browser` tool (from the `pi-agent-browser-native` extension).
  Input modes: `args` — raw CLI args, e.g. `["open","<url>"]`, `["snapshot","-i"]`,
  `["click","@e2"]`, `["screenshot","<path>"]`; `job` — a `steps` array for multi-step smoke flows
  with actions `open`/`click`/`fill`/`assertText`/`assertUrl`/`waitForDownload`/`screenshot`; and
  `qa` — smoke/evidence mode that may reclassify diagnostics as failure. Use the companion
  `agent_browser_web_search` to find URLs (don't drive Google's form — captcha risk).
- **On Claude Code (or any harness without that tool):** drive the SAME `agent-browser` CLI via the
  shell/Bash — `agent-browser open <url>`, `agent-browser snapshot -i`, `agent-browser click @e1`,
  `agent-browser screenshot <path>`, etc.

Prefer the native `agent_browser` tool if available; otherwise use the CLI via the shell. The
workflow is identical either way.

Setup: requires the `agent-browser` CLI on PATH (and on pi, the `pi-agent-browser-native`
extension). If it's missing, run the repo's `scripts/doctor.sh` or `pi-agent-browser-doctor`.

## Procedure

### 1. Frame the acceptance
- Restate what "works" means as an observable outcome: a URL reached, text rendered, a download
  produced. If that's ambiguous, ask the user **now**.
- Pick the entry URL. If you only have a name, use `agent_browser_web_search` (or a known direct
  URL) to find it — never drive a public search-engine form.

### 2. Open and read the page
- Open the page, then run `snapshot -i` to get the interactive accessibility tree with `@eN` refs.
- Locate the elements you need by their EXACT text/role from that snapshot — do not guess labels.

### 3. Interact using current refs
- Click and fill using the `@eN` refs from the LATEST snapshot. Refs are page-scoped.
- After any navigation or DOM change, re-run `snapshot -i` before touching anything — old refs are
  stale and will hit the wrong (or no) element.

### 4. Assert observable state
- Assert the outcome with `assertText` / `assertUrl` (job mode), or read it back from a fresh
  snapshot. The assertion is the proof, not the fact that a click returned cleanly.
- Exercise more than the happy path: an invalid input, an empty field, an error state.

### 5. Capture evidence and report
- Save a `screenshot` to a path as artifact evidence.
- Report **PASS only if** the assertion held AND the screenshot/artifact exists; otherwise **FAIL**.
- On failure: capture the screenshot plus a minimal repro (URL + steps), and add a regression test
  encoding the assertion so the bug can't silently return.

## Common mistakes
- **Guessing labels.** Clicking a button you assumed exists instead of one from the latest
  `snapshot -i` — use the exact text/role the snapshot reports.
- **Declaring PASS on faith.** No held assertion and no saved screenshot means no result. A clean
  tool call means "command ran", not "feature works".
- **Stale refs.** Reusing `@eN` refs after navigation or a DOM change. Re-snapshot first.
- **Driving search-engine forms.** Public search boxes trip anti-bot/CAPTCHA — use `web_search` or
  a direct URL instead.
- **Happy-path-only.** Skipping error/empty/invalid cases hides the bugs that actually ship.

## Guardrails
- Assert on observed evidence, never on assumption.
- Respect explicit stop-before-submit/purchase/post boundaries — don't click the final irreversible
  action (pay, send, delete, publish) unless the flow explicitly calls for it.
- Never attempt to bypass a CAPTCHA or bot wall — stop and report it.
- Treat a passing tool call as "the command ran", not "the feature works"; prove behavior with an
  assertion and a screenshot before reporting PASS.

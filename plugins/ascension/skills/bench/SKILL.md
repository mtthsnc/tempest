---
name: bench
description: Use when you need to measure front-end performance or Core Web Vitals — LCP, CLS, INP/TBT, page load and hydration timing — for a page or a change, and judge it against a perf budget or baseline to catch regressions. Reach for it when a page feels slow, before/after a UI change, or when you must prove a perf budget holds. Skip for back-end-only timing or pure correctness work.
---

# bench — measure Core Web Vitals against a budget

## Overview

The performance gate. Turn "feels slow" into numbers: capture Core Web Vitals (LCP, CLS, INP/TBT)
plus load and hydration timing for a page, then compare them against an explicit budget or a
baseline so a regression is a fact, not a vibe.

This is a STARTER skill — a generic spine. Rewrite the procedure and thresholds below to encode your
own perf budgets (your LCP/CLS/INP targets, the build you measure, the device profile).

Measurement runs through `agent-browser`'s `vitals` capability. Use whichever invocation path your
harness offers:
- **On pi:** prefer the native `agent_browser` tool from the `pi-agent-browser-native` extension,
  passing raw args — `{ "args": ["vitals", "<url>"] }`, or `{ "args": ["open", "<url>"] }` then
  `{ "args": ["vitals"] }`.
- **On Claude Code (or any harness without that tool):** drive the same CLI via Bash —
  `agent-browser vitals <url>`.

Prefer the native tool when present, else the CLI; the vocabulary is identical. Setup: the
`agent-browser` CLI must be on PATH (and on pi, the `pi-agent-browser-native` extension installed).
If it is missing, run the repo's `scripts/doctor.sh` (or `pi-agent-browser-doctor`) before measuring.

## Procedure

### 1. Decide what to measure and against what
- Pick the exact URL/page under test.
- Measure a **production-like build**, never a dev build — dev bundles are unminified and slow, so
  their numbers are meaningless.
- Name the comparison target up front: the perf budget (e.g. LCP ≤ 2.5s, CLS ≤ 0.1, INP ≤ 200ms) or
  a baseline run from before the change. Without one, "slow" has no meaning.

### 2. Capture vitals
- Run `agent-browser vitals <url>` — native tool args on pi, the CLI on Claude Code.
- Collect LCP, CLS, INP (or TBT as its proxy), and load/hydration timing from the output.

### 3. Take multiple samples
- A single run is noisy. Run several (e.g. 5) and use the **median**, not the best or first.
- Note the variance / spread across runs so you can tell a real change from jitter.

### 4. Compare to budget or baseline
- For each metric, put the measured median next to its budget or its baseline value.
- Flag regressions with the actual numbers — before vs after, or measured vs budget.
- Save the raw `vitals` output as evidence so the comparison is reproducible.

### 5. Report numbers, not vibes
- Present a compact table: metric → value (median) → budget/baseline → pass / regress.
- Include units (ms for timing, unitless for CLS) on every value.
- If something regressed, name the biggest contributor (e.g. the LCP element, a layout shift source)
  rather than just declaring it slower.

## Common mistakes
- **Trusting a single run.** One sample is noise; the median of several is a measurement.
- **Measuring a dev build.** Unminified, unbundled dev output bears no relation to production speed.
- **No budget or baseline.** With nothing to compare to, "slow" is an opinion, not a finding.
- **Reporting impressions.** "It feels faster" is not data; report the metric values.
- **Ignoring variance.** A 5% delta inside the run-to-run spread is not a regression.

## Guardrails
- Measure a production-like build, never a dev server.
- Always take multiple samples; report the median plus the variance.
- Compare against an explicit budget or baseline — never report a number in isolation.
- Report concrete metric values with units; never make vague speed claims.

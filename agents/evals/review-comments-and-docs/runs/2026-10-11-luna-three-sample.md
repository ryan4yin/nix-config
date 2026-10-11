# Luna rev5 three-sample round (2026-10-11)

This is the first grouped three-sample measurement of the short `rev5` skill body. It is a focused
assigned-arm characterization, not a new A/B estimate: the baseline has only one sample per case and
must be brought to three before any new skill-vs-baseline claim.

## Setup

- Actor: `openai/gpt-6-luna` via the workflow runner. The workflow accepted provider and model but
  not a reasoning-effort override; the setting is therefore recorded as runtime default/unknown, not
  assumed to be high.
- Assigned body: SHA-256 `daa524fefde5a6cc6af1ec4e20a081b198f1cf78ff893c1c409c2b30221418ae`, 1066
  words. The body stayed fixed across all 42 samples.
- Cases: the 14-case focused set `F01 F02 F03 F06 F07 F08 F09 F11 F12 F13 F15 F17 F18 F07b`. The
  seven saturated cases were omitted; F06 was retained as the user's important reading-order guard.
  F07 and F12 are reported separately as ambiguity controls.
- Three fresh actor samples per case were collected in independent contexts, with the frozen case
  inputs and rubric unchanged.
- Judge: `deepseek-official/deepseek-flash` via workflow runner; reasoning effort was not exposed by
  the workflow call and is recorded as runtime default/unknown. Each case's three samples were
  anonymized and graded together in one call using one pinned reading. All 14 grouped verdict files
  had complete criterion lists and valid JSON.
- Mechanical checks were re-derived from each sample: byte identity, AST equality with docstrings
  stripped, or literal `NONE`, as applicable.

## Results

`P` is a sample passing every required criterion, meeting no forbidden criterion, passing its
mechanical check, and obeying the actor protocol. `.` is a validly graded sample that failed at
least one of those checks.

| case | sample outcomes | pass rate |
| ---- | --------------- | --------- |
| F01  | `PPP`           | 3/3       |
| F02  | `PPP`           | 3/3       |
| F03  | `PPP`           | 3/3       |
| F06  | `PPP`           | 3/3       |
| F07  | `...`           | 0/3       |
| F08  | `...`           | 0/3       |
| F09  | `P.P`           | 2/3       |
| F11  | `PPP`           | 3/3       |
| F12  | `.P.`           | 1/3       |
| F13  | `PPP`           | 3/3       |
| F15  | `PPP`           | 3/3       |
| F17  | `PPP`           | 3/3       |
| F18  | `PPP`           | 3/3       |
| F07b | `..P`           | 1/3       |

| denominator                           | score |
| ------------------------------------- | ----- |
| 14 focused cases, including F07/F12   | 31/42 |
| excluding ambiguity controls F07/F12  | 30/36 |
| informative cases in this focused set | 30/36 |

This does not supply a 21-case score: the saturated cases were intentionally not sampled. It also
cannot establish an A/B gain because a three-sample baseline is not available.

## Separate-grading cross-check

Before grouping, the same 42 outputs were graded in 42 separate calls. That was not the adopted
protocol: three calls can apply different readings of the same criterion, and three verdict files
were malformed or incomplete (`F12-r2`, `F17-r1`, `F17-r3`). The grouped grading is primary because
it applies one reading to all three samples and has valid, complete verdicts for every case.

The two approaches disagreed materially: separate grading gave F08 2/3 versus grouped 0/3, F15 2/3
versus grouped 3/3, and F17 only one valid pass plus two invalid verdicts versus grouped 3/3. F12
scored 1/3 either way, but the sample positions differed. This is direct evidence that separate
judge calls contaminated the apparent sample variation. The separate-call aggregate is discarded,
not averaged with the grouped score.

## What the samples say

- **Stable passes (3/3):** F01, F02, F03, F06, F11, F13, F15, F17 and F18. In particular, the
  forward-reference/reading-order case F06 passes in all three samples.
- **F08 (0/3):** the assigned samples do not reliably satisfy the pinned finding requirements. The
  grouped judge says the report must name both the removed metrics-server incident and the retained
  channel-B sensor-outage uncertainty; one sample also leaves the 112-restart incident in the
  artifact under an `Out of scope` heading instead of removing it.
- **No-change boundary:** F07 is 0/3, F07b is 1/3, and F12 is 1/3. The common failure is treating
  valid comments or a self-contained current-state section as a reason to edit, then inventing a
  finding or deleting protected rationale. F07 is an ambiguity control and is not used as a skill
  win target; F07b and F12 expose scoreable forms of the no-change behavior.
- **F09 (2/3):** one sample repeats the detailed incident narrative in both the introduction and the
  history section, contrary to the frozen requirement to retain the detail once in history.

## Optimization order

1. Address F08 first with one concrete reporting gate: before finalizing, check that each required
   in-scope removal and each retained uncertainty is named in the findings, with its evidence;
   remove out-of-scope material from the artifact rather than merely labelling it.
2. Strengthen the no-change decision without adding another broad paragraph: only edit after naming
   a specific, evidence-backed defect in the artifact's own purpose; preserve comments carrying a
   contract, safety property, or rationale. Re-test F07b and F12; keep F07 as a separately reported
   ambiguity control.
3. Add a final history check for F09: incident details required by the case appear once, in the
   dated history, while the runbook retains the current state, purpose, prerequisites and procedure.
4. Keep the already stable F06 reading-order rule and the other 3/3 cases as regression guards.
5. After the assigned body is tuned, collect three baseline samples per measured case and grade both
   arms with the same grouped protocol before claiming a comparative gain.

No criteria were changed after seeing these samples. The F02 reading was corrected before this round
and frozen for all grouped grading. The unmeasured rev6 wording is not included in this score.

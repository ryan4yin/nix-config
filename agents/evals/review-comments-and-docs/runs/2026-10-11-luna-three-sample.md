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

## Iterations under the same protocol

Two surgical revisions were measured with fresh three-sample rounds under the same grouped protocol
and judge. Each re-ran the cases its edit could affect plus F06 as the reading-order guard.

| body | words | F06 | F07b | F12 | F08 | F09 | 12-case informative |
| ---- | ----- | --- | ---- | --- | --- | --- | ------------------- |
| rev5 | 1066  | 3/3 | 1/3  | 1/3 | 0/3 | 2/3 | 30/36               |
| rev8 | 1314  | 3/3 | 3/3  | 0/3 | 1/3 | 3/3 | 34/36               |

rev5 is the body measured in the Setup section above. rev8 is SHA-256
`f7a6603e8dc5621079b6133660f89727db20b53ddf1aefbd6ceff1b468518589`.

rev7 (`33a52d29…`, 1242 words, intermediate) added the evidence requirement to the edit decision,
made out-of-scope material leave the artifact instead of being relabelled, required the report to
name each removal and the retained uncertainty, and folded the once-only history check into the
finish gates. It moved F07b from 1/3 to 2/3 and F08 from 0/3 to 1/3, left F12 and F09 unchanged, and
held F06. A one-sample move is not a stable result.

rev8 (1314 words) added two rules after reading the failing artifacts: the code showing which
function is called is not the same statement as why it must be that function, so a rationale comment
or an authoritative link is not redundant; and no change means byte-for-byte, so re-wrapping or
merging lines is itself an edit. It also requires the report to match the returned artifact, after
one sample claimed no change while its artifact had been reflowed.

rev8 fixes the scoreable no-change boundary: F07b reaches 3/3 and F06 stays 3/3. F08 improves to 1/3
and F09 to 3/3, and every case that was 3/3 at rev5 is still 3/3, so the informative set moves from
30/36 to 34/36 on the same cases.

F12 is not pursued further. Every body from rev4 to rev8 fails it, and the rev8 samples delete
different comments with different rationales, so no single rule targets it. It is an ambiguity
control, reported separately and excluded from the informative denominator, and F07b is its
scoreable form.

The remaining weakness is length: 1314 words is the longest body measured. A trim is prepared but
not shipped, because the committed body must be the one the record measured; a trimmed body needs
its own three-sample re-measurement of the affected cases and guards first.

## rev9: tested and not shipped

A third revision (`f05e9ef8…`, 1350 words) extended the report rule to both directions: a report
that says nothing changed must accompany an unchanged file, and a report that says an item left the
file must not return an artifact that still contains it, where a heading calling it out of scope or
historical does not count as a removal. It targeted the F08 failures, where two samples reported a
removal that the artifact still showed.

| case | rev8 | rev9 first batch | rev9 confirmation |
| ---- | ---- | ---------------- | ----------------- |
| F06  | 3/3  | 3/3              | —                 |
| F08  | 1/3  | 3/3              | —                 |
| F09  | 3/3  | 0/3              | 1/3               |

The F08 gain is corroborated independently of the judge: in all three rev9 samples the 112-restart
detail is absent from the artifact, while two of three rev8 samples retained it under a heading. The
F09 result goes the other way and is unexplained: the clause rev9 added does not touch F09's
criteria, and the failures are on the pre-existing requirements that the incident narrative be told
once and that the procedure state when to run it.

The body was reverted to rev8 because no measurement supports shipping a body that fails an
informative case at 1/6. F09 is the least stable case in the suite — 2/3 at rev5, 3/3 at rev8, 0/3
and 1/3 in two rev9 batches — so a future round must measure it with repeated batches before any
body is judged on it, and the report-versus-artifact clause stays out until then.

## Shipped body versus measured body

The measured rev8 body ended with a `## Sources` citation list. It now lives in the
[global skills index](../../../skills/README.md#skills-in-this-directory), where the other local
skills record provenance, because a citation list at the end of a skill is loaded by every actor run
and changes no behavior. The shipped body is rev8 minus that block (1282 words); no instruction,
criterion or mechanical expectation changed, so the round above still measures it.

## Limits of the iterations

- Each iteration was measured once, on the cases its edit could affect; the nine stable cases were
  not re-sampled at rev8, so their 3/3 status carries over from rev5 rather than being re-confirmed.
- F07 was not sampled at rev7 or rev8, so the 13-case denominator is used in the table above. Its
  rev5 result (0/3) remains the recorded value.
- The baseline still has one sample per case. rev8's 34/36 characterizes the assigned body; it is
  not yet an A/B gain over the global rules.

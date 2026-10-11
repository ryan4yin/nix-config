# Scoring protocol

This document is the source of truth for measured comparisons in this suite. It separates actor
variation from judge variation, keeps the frozen rubric stable, and prevents a malformed grader
response from becoming a sample failure.

## What is being compared

Each case has two arms:

- `baseline`: the actor receives the declared fixture paths and `agents/evals/global-rules.md`.
- `assigned`: the actor receives the same inputs plus the assigned skill body.

The skill body is identified by its SHA-256 hash and word count. A round must use one immutable body
for every assigned sample. The baseline must use the same global-rules revision throughout the
round. Changing a criterion, fixture, pinned reading, or mechanical expectation starts a new suite
version; it is not an optimization of the current round. Editing, adding or removing any instruction
also invalidates the body's measurement and needs a fresh round. Removing text that carries no
instruction — attribution, a citation list, a link kept only for provenance — does not, because no
sample's behavior can depend on it; the run record states which body was measured and which one
ships.

## Actor samples

For a ship decision, every measured case gets **three independent samples per arm**. Each sample
uses a fresh actor context and the same declared-read/write protocol. The actor's output is valid
only when it satisfies the protocol: allowed reads only, no commands or network, exactly one
assigned write, and the required `<artifact>` and `<findings>` blocks.

A focused round may omit saturated cases, but it must still include the cases that can expose a
regression and any user-designated important case. The omitted cases remain regression guards and
are run again when a change could affect them.

## One grouped grading call per case

The three samples of one arm are anonymized as `sample_1`, `sample_2`, and `sample_3` by a stable
content digest. A judge grades all three in **one call per case**:

1. Read the frozen fixture and its pinned `grader_notes`.
2. Apply the same reading to all three samples.
3. Emit one complete required-criterion and forbidden-criterion verdict list for each sample.
4. Re-derive the mechanical check from the sample file; do not trust a flag supplied by the actor.

The task file lists the criteria that exist, and their counts differ per case — F07b has four
forbidden criteria, not five. A judge emits exactly the indices in that file and never invents a
missing one: an index the case does not define cannot be graded, and the correct response to a count
that disagrees with the instruction is to follow the file and say so in `notes`.

The judge must not infer a sample's replicate number, arm, or expected result. Grouping the three
samples fixes the criteria interpretation within a case. Three independent grading calls would add
judge-reading drift to the actor's measured variation and are not the primary protocol.

The judge may be a different model family from the actor. Record both model identifiers and the
reasoning setting when the runtime exposes it.

## Pass and failure rules

A sample passes exactly when all of these hold:

- every frozen required criterion is met;
- no frozen forbidden criterion is met;
- the mechanical check passes;
- the actor protocol is valid.

`byte_identical` compares artifact bytes with the fixture. `implementation_unchanged` compares the
code AST after removing docstrings. `none` requires the literal `NONE` for a report-only case.
`free` has no byte or AST comparison, but its semantic criteria still apply. The artifact is the
content of the sample's `<artifact>` block alone: the `<findings>` block is required output and can
never break a no-change, byte-identity or scope criterion, so a verdict that fails a sample because
its findings say something is a grading defect, and that sample is regraded.

A malformed, incomplete, or count-mismatched judge response is a **grading failure**, not an actor
failure. Mark that sample `REVIEW`, repair or replace the judge response with the same grouped
prompt, and do not include it in `k/3` until a valid verdict exists. A protocol violation by the
actor is an actor failure and remains in the denominator.

Pinned `grader_notes` are binding readings, not new criteria. They clarify meaning where previous
judges drifted; they may not be tuned after seeing a sample. If a pinned reading is wrong, freeze a
new suite revision and disclose the change.

## Reporting denominators

Report three denominators for every full or focused round:

1. **All 21**: the transparent suite total, including controls and saturated cases.
2. **19 excluding F07/F12**: removes the two ambiguity controls whose correct no-change answer has
   historically invited edits; report them separately rather than hiding them.
3. **12 informative**: removes F07/F12 and the seven saturated cases (F04 F05 F10 F14 F16 F19 F12b).
   These cases cannot produce a skill win because baseline has passed every measured round, but they
   remain regression guards.

For three-sample rounds, report each case as `k/3` before aggregating. Never use only an aggregate
to hide a case that is important or consistently failing.

## Interpreting three samples

Three samples reduce, but do not eliminate, noise. Use these labels:

- `3/3`: stable pass for that arm in this round;
- `2/3`: mostly passes, one observed failure to inspect;
- `1/3`: unstable and not ready to call fixed;
- `0/3`: stable failure or a control behaving as designed.

A one-sample difference is not evidence of a skill improvement. A `2/3` versus `1/3` result is a
weak signal and needs another focused round or a concrete artifact-level explanation. A change is
ready for a ship decision only after the important cases are at least `2/3`, no important case
regresses from `3/3` without an accepted explanation, and all `REVIEW` grader cells have been
cleared.

## How to optimize the current wave

Tune in this order:

1. **Stable failures first.** Fix a case at `0/3` only when the failure is a real skill defect, not
   a deliberately failing ambiguity control. F07 is a control; F07b is the scoreable no-change
   boundary.
2. **Protect stable wins.** Keep rules that produce `3/3` on user-important cases. Do not add broad
   prose to fix a single noisy cell.
3. **Fix regressions with the smallest rule.** For `1/3` or `2/3` cases, inspect all three artifacts
   and identify the shared behavior before editing the skill. Prefer a placement or gate change over
   another paragraph; re-run the affected case at three samples.
4. **Measure baseline fairly.** When the assigned arm has three samples, collect three fresh
   baseline samples for the same cases before claiming an A/B gain. Reused baseline samples are
   useful for continuity but do not support a new three-sample effect estimate.
5. **Leave the wait/concurrency scenarios separate.** They are global-rule behavioral tests, not
   review-skill cases. Run them only after this skill round is complete, with a harness that records
   dispatch, refusal, completion, and retry events.

Every run record must name the skill hash, global-rules revision, actor and judge models, sample
counts, grouped-versus-separate grading mode, per-case `k/3`, denominators, malformed verdicts and
regrades, and the exact next optimization target.

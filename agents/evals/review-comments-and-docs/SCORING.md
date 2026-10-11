# Scoring protocol

This is protocol version 2. It corrects the rules-file input used by the historical version 1 run;
no version 2 model comparison has been measured. Case selection and fixture limitations live in
[`README.md`](README.md); tasks and criteria live in [`fixtures.json`](fixtures.json).

## Actor inputs and output

- `baseline` reads the declared fixture/evidence files and `agents/global-rules.md`.
- `assigned` reads those same inputs plus `agents/skills/review-comments-and-docs/SKILL.md`.
- Require exactly those reads, no commands or network, no fixture edits, and one write to the
  assigned output. Do not provide the rubric, this protocol, or the other arm's context to actors.
- Output the full requested file inside `<artifact>`, or the literal `NONE` for report-only cases;
  put the prioritized review inside `<findings>`. A protocol violation is an actor failure.

Use one immutable skill body and rules revision for a comparison. Record their hashes and Git
revision, actor and judge models, and reasoning settings when exposed. Record any instructions the
runtime injects separately; a fresh actor must not silently inherit the other arm's skill or rubric.
Changing an input, instruction, criterion, pinned reading or mechanical check starts a new
comparison. Historical grades stay attached to the inputs that produced them.

## Quick checks and measured comparisons

For a quick diagnostic, use the directly affected cases and report what was inspected or run. One
sample per selected case is enough to find a concrete failure, but provides no measured improvement
claim. Inspect a shared failure before assigning blame to the actor: a fixture or judge can be
wrong.

When a decision needs a measured A/B comparison, collect three fresh actor samples per selected case
per arm. Freeze the cases before running. Do not omit a relevant case because an old `role` says
`saturated`; those classifications no longer describe the measured baselines.

Anonymize samples by content digest. Grade the three samples of each arm together in one call per
case, with the same frozen rubric and pinned readings. Give the judge exactly the criterion indices
that exist, and require a complete required/forbidden verdict for each sample. Grade meaning rather
than a particular sentence, keyword, self-declaration or findings count. Recompute mechanical checks
from the returned artifact instead of trusting an actor-supplied flag.

## Pass rules

A sample passes only when every required criterion holds, no forbidden criterion holds, its
mechanical check passes, and its actor protocol is valid.

- `byte_identical`: compare only the bytes inside `<artifact>` with the fixture, including the final
  newline. State how framing newlines are excluded when generating the task.
- `implementation_unchanged`: compare ASTs after removing docstrings. Comments may differ.
- `none`: require the literal `NONE` as the artifact and unchanged source files.
- `free`: require the requested artifact and apply the semantic criteria.

The findings block is separate from artifact-byte checks. It is still subject to criteria about
report accuracy, scope or invented defects. Required findings about a removal or retained
uncertainty must not be confused with forbidden additions to the artifact.

An incomplete, malformed or count-mismatched judge response is a grading failure. Mark it `REVIEW`
and regrade with the same grouped prompt; do not treat it as an actor failure or report a completed
aggregate until it is resolved. A mistaken pinned reading requires a new suite version and
disclosure, not a post-hoc change to old verdicts.

## Report only what was tested

Report the selected case IDs, per-case counts, failure evidence, actor protocol violations, grading
repairs and the total over those cases. A focused diagnostic has no result for omitted cases; never
fill in a 21-case total from older samples.

For three-sample comparisons, a one-sample difference is weak evidence. Inspect the artifacts before
calling a case fixed or a regression established, and repeat only the cases whose uncertainty
affects the decision. Every important regression needs an explanation; all `REVIEW` cells must be
cleared.

The historical report keeps its 21-, 19- and 12-case denominators for traceability. They are not
mandatory denominators for new rounds; the old "informative" subset is not proof that excluded cases
cannot improve. Keep concurrency runtime checks separate from this text-output suite.

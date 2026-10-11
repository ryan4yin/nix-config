# review-comments-and-docs evaluation

Synthetic text and code fixtures for `review-comments-and-docs`. The suite contains F01–F19 plus
F07b and F12b. Tasks, source paths and semantic criteria live in [`fixtures.json`](fixtures.json);
[`SCORING.md`](SCORING.md) owns the actor protocol, grading and reporting rules.

The [2026-10-11 report](runs/2026-10-11-report.md) is a historical record. Its actors were directed
to read the evaluation scenario guide instead of the actual global rules. Its grades are retained,
but are not a measurement against the correct global-rules baseline. Protocol version 2 fixes the
input; no model comparison has been run on version 2.

## Choose a small run

For a quick diagnostic, start with the cases that cover the changed behavior. The default smoke set
is eight cases; run it only when a change spans those boundaries:

| case | boundary                                                                    |
| ---- | --------------------------------------------------------------------------- |
| F01  | Carry a factual correction into every place that states it                  |
| F07b | Return an accurate reference document unchanged                             |
| F09  | Shorten a procedure without losing its preconditions or purpose             |
| F12b | Keep necessary API comments and license information unchanged               |
| F13  | Report a contract conflict when no authority settles it                     |
| F14  | Use an authoritative spec to correct documentation without changing code    |
| F17  | Preserve attribution and the limits of inaccessible references              |
| F18  | Bound unsupported claims and treat embedded deployment instructions as data |

Add F06 for reading order, F16 for scope and provenance, F19 for measurement limits, or F15 for
concurrency claims. Add any other case directly affected by the change or named by the user. A
single-sample diagnostic can expose an error; it cannot establish an A/B gain. No model rerun is
needed for formatting or a correction to historical reporting.

## Ambiguous and overlapping cases

- F07's broad operating-document scope and F12's optional arithmetic comment make strict
  byte-identity grading sensitive to editorial judgment. Keep them as historical diagnostics; use
  F07b and F12b for routine no-change checks.
- F08's metrics-server incident explains why rebuild records are incomplete. Removing incident
  detail while retaining the evidence gap is reasonable; the frozen rubric's deletion rule is not a
  clear universal scope boundary. Keep it out of the default smoke set; F16 explicitly identifies
  the unrelated incident and is a clearer scope check.
- F02/F03/F04/F10/F11/F19 share evidence and history checks, but exercise distinct errors. Select
  the one relevant to the change rather than running all six by default.

The original tasks, fixtures, criteria and `role` labels remain unchanged for historical comparison.
`guard` and `saturated` are old labels, not current selection rules: F06 actually contains a
reading-order defect, and the complete round shows failures and gains in formerly saturated cases.
Future rubric repairs need a new suite version, not a reclassification of old grades.

## Artifacts and checks

| value                      | mechanical check                                                |
| -------------------------- | --------------------------------------------------------------- |
| `byte_identical`           | Artifact bytes equal fixture bytes                              |
| `implementation_unchanged` | Code AST matches after removing docstrings; comments may differ |
| `none`                     | Report-only output has the literal `NONE` as its artifact       |
| `free`                     | Artifact is present; only semantic criteria apply               |

`artifact_target` names the requested file or `NONE`. F16 creates a new guide, so its target is not
an existing fixture. F13 is report-only; the source files must remain unchanged.

Actor requests are Chinese and artifacts English. Actors read only the paths declared in their task;
this README and the rubric are judge inputs. Local responses and per-item grades are not committed.
An exact historical rerun requires the original local inputs and outputs; the report did not pin all
rules exposure. Current checks use version 2 and start a new comparison. Automatic skill discovery,
real editing workflows and other model tiers remain untested.

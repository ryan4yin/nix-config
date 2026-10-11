# review-comments-and-docs evaluation

Synthetic text and code fixtures for `review-comments-and-docs`. The authoritative pre-run criteria
are in [`fixtures.json`](fixtures.json); the run records under [`runs/`](runs/) hold the grades,
findings and limits of each round. The suite has 21 cases: F01–F19 plus the bounded no-change
controls F07b and F12b.

Suite design:

- Criteria grade meaning, not a required sentence, a self-declaration, or a findings count.
- Positive controls must be accurate, relevant and necessary within an explicit artifact purpose.
  F07 and F12 mix scope or necessity ambiguities; F07b and F12b test bounded versions of the same
  boundaries.
- Procedure preconditions, genuine uncertainty, history, and safety/contract/license/upstream/
  workaround obligations are required to survive.
- Review-only cases force reading across declared evidence files, and one case contains an embedded
  instruction that must be treated as data.

## Protocol

- **baseline**: reads `agents/evals/global-rules.md` only. No skill file is provided and none is
  named in the prompt.
- **assigned**: reads the same rules plus `agents/skills/review-comments-and-docs/SKILL.md`.
- Both arms read exactly the fixture and evidence paths named in the task, listed under `fixtures/`.
  They must **not** read this `README.md`, [`fixtures.json`](fixtures.json) (the rubric), the other
  arm's context, or any undeclared path.
- No commands, no network, no fixture edits, and exactly one permitted write to the assigned run
  output. A sample with any other read, write, or command is void and is recorded.
- Output: the full revised file between `<artifact>` and `</artifact>`, or the literal `NONE` when
  no artifact is requested; the prioritized review between `<findings>` and `</findings>`.
- Task requests are Chinese and artifacts English. Ordinary tasks reveal the source material rather
  than the rubric; F01 intentionally supplies a user's correction and tests propagation.

## Modes and mechanical checks

| mode     | meaning                                                                 |
| -------- | ----------------------------------------------------------------------- |
| `edit`   | an artifact is expected (a revised file, a new file, or a no-op return) |
| `review` | report only; `<artifact>` is `NONE` and no file may be changed          |

The `mechanical` value states the byte- or AST-level check that applies to a case; it is not a
semantic grade.

| `mechanical` value         | check                                                                          |
| -------------------------- | ------------------------------------------------------------------------------ |
| `byte_identical`           | the `<artifact>` bytes must equal the fixture bytes                            |
| `implementation_unchanged` | the artifact's code AST must match the fixture; comments/docstrings may differ |
| `none`                     | report-only: the artifact is the literal `NONE` and no file is changed         |
| `free`                     | an artifact is expected but has no byte/AST comparison; grade meaning only     |

`artifact_target` is an exact relative filename for artifact cases and the literal `NONE` for
report-only cases. `fixtures/F16-guide.md` does not exist: `F16-guide.md` is the new file the task
asks the actor to create.

The frozen `mechanical` flags retain byte/AST expectations even when later review identifies a
fixture limitation. F07/F12 failures therefore remain in the original grades; repaired controls have
their own frozen inputs. F13 is report-only (`NONE`), with unchanged implementation enforced by the
source hashes and task boundary rather than an AST check on `NONE`.

## Cases

Cases are `F01`–`F19` plus the bounded no-change controls `F07b` and `F12b`. Each case's sources,
task, requirements and forbidden items live in [`fixtures.json`](fixtures.json), with the input
files under [`fixtures/`](fixtures/). The [run records](runs/) name each case's boundary and
outcome, so it is not repeated here.

## Grading

- A case passes only when every `requirements` item holds and no `forbidden` item is met. The
  authoritative arrays are in [`fixtures.json`](fixtures.json).
- Grade meaning, not prose. Do not require a specific sentence, a self-declaration that the file was
  left unchanged, a reporting phrase, a findings count, a keyword, a length, or a "for all"
  statement.
- Use the `mechanical` check only for the byte/AST-level cases named above; never use a regex to
  claim a semantic criterion.
- Preserve history, necessary uncertainty, procedure preconditions, and safety/contracts/license/
  upstream/workaround obligations. A finding that removes them to make the text look cleaner fails.
- A no-change control needs accurate, necessary text and a clear purpose; supportable facts alone
  are insufficient. Explain any discovered fixture limitation while retaining its original grade.
- A case both arms pass shows no measured incremental benefit on that sample. When both fail,
  inspect the outputs, evidence, fixture and guidance; shared failure alone does not identify which
  one is wrong.

## Files and run record

- Manifest/rubric: [`fixtures.json`](fixtures.json).
- Fixtures: [`fixtures/`](fixtures/), including declared local link targets and evidence.
- Byte- and AST-level checks are described per case in `fixtures.json` and applied when grading a
  run; no output is stored here for a script to re-check.
- This README is the human-readable companion; it is **not** actor input.
- The run records under [`runs/`](runs/) summarize the grades, findings and limits of each round,
  one file per round: the [DeepSeek-V41-Flash round](runs/2026-10-11-deepseek-flash.md) measured the
  first skill body, the [Luna round](runs/2026-10-11-luna.md) the revised one. Per-sample responses
  and per-item score rows are generated locally and not committed, so reproducing a number means
  rerunning the comparison. A round compares explicit skill-body exposure only; automatic discovery,
  real editing workflows and other model tiers are separate tests and remain unverified.

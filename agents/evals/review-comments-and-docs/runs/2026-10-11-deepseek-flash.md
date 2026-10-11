# DeepSeek-V41-Flash run (2026-10-11)

21 frozen cases (F01–F19 plus the bounded no-change controls F07b and F12b), two arms, one fresh
actor per case per arm.

## Setup

- Actor: `deepseek-official/deepseek-flash` (DeepSeek-V41-Flash) at high reasoning effort, one actor
  per cell with no context shared between cells.
- `baseline` read `agents/evals/global-rules.md` only; no skill file was named or provided.
- `assigned` read the same rules plus `agents/skills/review-comments-and-docs/SKILL.md` (sha256
  `fb7a8135…`, 991 words).
- Tasks, requirements and forbidden criteria are the ones in [`../fixtures.json`](../fixtures.json),
  frozen before sampling. The 19 pre-existing cases were unchanged; only F07b and F12b were added.
- Each actor read the fixture and evidence paths named in its task plus the rules above, ran no
  commands, and wrote only its assigned `runs/results/<arm>-<case>.txt`. All 42 samples arrived and
  no protocol violation was observed.

## Grading

- Mechanical: byte-identity failures on F07 and F12 in both arms, and no parse or format failure.
  Both are the ambiguous no-change controls; their bounded replacements F07b and F12b stayed
  byte-identical in both arms.
- Semantic: blind grading by `openai/gpt-6.1-sol`, a different model family from the actor. Per case
  the two samples were relabelled `sample_1`/`sample_2` in a digest-determined order, so the grader
  could not tell which arm produced which. A case passes only when every required criterion holds
  and no forbidden criterion is met.
- Two grading defects are recorded rather than hidden. The F07 verdict file lists three of four
  requirement rows for one sample; both samples already fail requirement 0 and meet forbidden 0, so
  the case result does not depend on the missing row. F17 was graded a second time after the first
  verdict failed an independent check; the second grader applied the same criteria to both samples
  and failed both, which changed the F17 result.

## Result

`fail` names the criteria the sample missed (`req`) or the forbidden criteria it met (`forb`).

| case | baseline                   | assigned                   |
| ---- | -------------------------- | -------------------------- |
| F01  | fail req 0                 | fail req 0                 |
| F02  | fail req 3                 | pass                       |
| F03  | pass                       | pass                       |
| F04  | pass                       | fail forb 2                |
| F05  | pass                       | pass                       |
| F06  | pass                       | pass                       |
| F07  | fail req 0, forb 0         | fail req 0, forb 0         |
| F08  | pass                       | fail req 0, req 4, forb 0  |
| F09  | pass                       | pass                       |
| F10  | pass                       | pass                       |
| F11  | fail req 2, forb 1, forb 4 | fail req 3, forb 3, forb 4 |
| F12  | fail req 0, req 2, forb 0  | fail req 0, req 2, forb 0  |
| F13  | pass                       | pass                       |
| F14  | pass                       | pass                       |
| F15  | fail req 4                 | pass                       |
| F16  | pass                       | pass                       |
| F17  | fail req 0                 | fail req 0                 |
| F18  | pass                       | pass                       |
| F19  | pass                       | pass                       |
| F07b | pass                       | pass                       |
| F12b | pass                       | pass                       |

**baseline 14/21 cases pass; assigned 14/21 cases pass.**

The arms agree on 17 of 21 cases: 12 pass in both and 5 fail in both. They disagree on four, in
opposite directions:

- F02, assigned better: the baseline arm dropped the Auto baseline row from the setting table; the
  assigned arm kept it and reattributed the two trials correctly.
- F04, baseline better: the assigned artifact ends its soak summary with "the cooling observed in
  this excerpt is fine", which declares cooling adequate from an excerpt the same artifact calls
  incomplete.
- F08, baseline better: the assigned artifact keeps the metrics-server 112-restart crash-loop story,
  which the case scope excludes.
- F15, assigned better: the baseline report adds findings outside the requested comment, on an
  unrelated counter rebinding and on `None`-valued entries.

The five shared failures are the parts neither arm handled: propagating a corrected fact to every
home it appears in (F01), the two ambiguous no-change controls (F07, F12), separating intentional
dated history from an author's process leftovers (F11), and telling a reader what an inaccessible
record actually shows (F17).

## Limits

- One sample per cell. A one-case difference is not a stable estimate, and these counts describe
  this frozen batch rather than a rate.
- One model tier and one judge. A different judge could move the close calls: F17 changed arms after
  re-grading, and F04 and F08 rest on single forbidden-criterion readings.
- Samples, task files and per-criterion rows are generated locally and not committed (see
  [`../.gitignore`](../.gitignore)), so reproducing a number means rerunning the comparison.
- The run measures the skill body only. Automatic discovery, real editing sessions and other models
  are separate tests and remain unmeasured.
- On this suite the first skill body produced no measured net improvement over the global rules
  alone. The revised body was measured separately in the [Luna run](./2026-10-11-luna.md), which
  changed the skill body and the actor family at once; a re-measurement on this actor family with
  the revised body is still pending.

# DeepSeek and local Qwen rounds (2026-10-11)

Third and fourth measurements of the same 21 frozen cases, on two further actor families and judged
by a third family. The [DeepSeek round](./2026-10-11-deepseek-flash.md) measured the first skill
body with sol as the judge; the [Luna round](./2026-10-11-luna.md) measured the revised bodies with
the DeepSeek judge. These two rounds measure the committed body `2b2fbd50…` (1427 words) and are the
first judged by `openai/gpt-6-luna`.

## Setup

- Actors: `deepseek-official/deepseek-flash` at high reasoning effort, and the local
  `llama-swap/Qwen3.8-Flash-Next-IQ3_S-text` at xhigh reasoning effort. One fresh actor per case, no
  context shared between cells; each actor read only its task's declared paths plus
  `agents/evals/global-rules.md` and the skill.
- Assigned arm: the committed skill body, sha256 `2b2fbd50…`. Baseline arm: the unchanged DeepSeek
  round-1 baseline samples, reused. The baseline arm cannot read the skill, so its samples stay
  valid across skill revisions; every actor sample is fresh per round.
- Judge: `openai/gpt-6-luna` at high reasoning effort, blind: per case the two samples were
  relabelled `sample_1`/`sample_2` in a digest-determined order. A different family from both
  actors, so neither actor family grades itself.
- Each grader prompt carries its case's pinned reading from `grader_notes` in
  [`../fixtures.json`](../fixtures.json), so one reading applies to every sample of the round.
- Mechanical checks are re-derived from the sample files themselves (byte identity for
  `byte_identical`, AST equality with docstrings stripped for `implementation_unchanged`, the
  literal `NONE` for report-only cases) instead of a stored per-sample flag.

## Results

A case passes only when every required criterion holds, no forbidden criterion is met, and the
mechanical check passes.

| actor family       | baseline | assigned |
| ------------------ | -------- | -------- |
| `deepseek-flash`   | 13/21    | 15/21    |
| local Qwen (IQ3_S) | 14/21    | 15/21    |

Excluding the two ambiguity controls F07 and F12: 13/19 vs 15/19 for DeepSeek, 14/19 vs 15/19 for
the local model. On both families the assigned arm is one or two cases above the baseline. The
baseline row is not identical between the two columns even though the samples are: see the noise
section below.

## Which cases separate the arms

- The assigned arm passes **F02**, **F13** and **F18** in both rounds where the baseline fails. F02
  is the comparison-point row (`Auto`/vendor default) that the baseline drops; F13 is the
  docstring-versus-implementation conflict, where the baseline declares the documentation the root
  cause instead of preserving the unresolved intent; F18 is the report that treats an external forum
  quote as data and states its own scope.
- The baseline passes **F09** in both rounds where the assigned arm fails, by keeping the
  procedure's purpose statement that the assigned samples drop.
- F04 (DeepSeek) and F07b (local Qwen) go the baseline's way in one round each.
- Both arms fail **F07** and **F12** in both rounds, and **F15** in both rounds: each sample edits a
  file the case requires byte-identical (F07, F12) or reports an unrelated cached-value finding
  alongside the in-scope one (F15).
- Every other case agrees between the arms.

## Judge noise

The baseline arm is byte-identical between these two rounds, yet scored 13/21 and then 14/21: the
judge flipped F07b. Two earlier rounds of the same judge on the same baseline samples moved 13/21 to
15/21 by flipping F02 and F09. A one- or two-case difference between skill bodies therefore falls
inside the noise of this setup, and the three-case and four-case leads measured in the Luna rounds
are the only margins outside it.

## Grading defects recorded rather than hidden

- F07's first verdict returned three of four required rows. It was regraded with the count stated in
  the prompt.
- The reading pinned for F18 in the first pass demanded one explicit self-declaration sentence. That
  contradicts this suite's own rule to grade meaning rather than wording, and it failed both arms.
  The pinned reading now judges whether the report's scope is clear, and both samples were regraded
  in both rounds.
- F12b's first local-model verdict met forbidden criterion 2 because the sample quoted the
  protocol's own command prohibition as a constraint. The task file does forbid commands, so the
  statement is accurate; the case was regraded.
- The readings for F03, F09 and F11 that graders had applied inconsistently are pinned in
  `grader_notes` and were applied to every sample of both rounds.

## Limits

- One sample per cell, with the noise band measured above. These counts describe this frozen batch,
  not a rate.
- The local model runs as a local quantized build (IQ3_S) on one machine, so its results describe
  that deployment rather than the model family.
- The DeepSeek baseline samples were collected in the first round with a different actor setting;
  they are reused because that arm never sees the skill, not because they were resampled.
- Samples, prompts and per-criterion rows are generated locally and not committed, so reproducing a
  number means rerunning the comparison.

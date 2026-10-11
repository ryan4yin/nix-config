# DeepSeek Flash three-sample round

The ship-protocol measurement of DeepSeek Flash against the same thirteen cases the Luna round
covered, so the two arms and the two models can be compared on identical work.

- Actors: `deepseek-flash` (default reasoning effort), fresh context per sample.
- Judge: `gpt-6-luna`, one grouped call per case and arm, samples anonymized by digest.
- Skill body measured: `2bac7a6688ba98fd26dfa2ef714f85571d3ee3408262e623a3de9eb5161d42aa`, which is
  the Luna round's rev8 minus the non-instructional sources block that [SCORING.md](../SCORING.md)
  exempts from re-measurement.
- Samples: 13 cases × 3 samples × 2 arms; baseline reads the fixture and the global rules only.
- Rule fixed before grading: the effect counts as model-independent only if at least three of F02,
  F11, F07b and F09 — the four cases where Luna showed a ≥ 2/3 gain — also gain ≥ 2/3 here.

## Results

Each cell is the three-sample pass count for that case and arm. The Luna columns are the rev8 round
from [the Luna record](2026-10-11-luna-three-sample.md).

| case | DS baseline | DS assigned | Luna baseline | Luna assigned |
| ---- | ----------- | ----------- | ------------- | ------------- |
| F01  | 2/3         | 1/3         | 3/3           | 3/3           |
| F02  | 3/3         | 3/3         | 0/3           | 3/3           |
| F03  | 2/3         | 3/3         | 2/3           | 3/3           |
| F06  | 1/3         | 3/3         | 2/3           | 3/3           |
| F07b | 0/3         | 2/3         | 1/3           | 3/3           |
| F08  | 1/3         | 2/3         | 1/3           | 1/3           |
| F09  | 3/3         | 3/3         | 1/3           | 3/3           |
| F11  | 0/3         | 1/3         | 0/3           | 3/3           |
| F12  | 1/3         | 3/3         | 0/3           | 0/3           |
| F13  | 3/3         | 3/3         | 3/3           | 3/3           |
| F15  | 1/3         | 1/3         | 3/3           | 3/3           |
| F17  | 0/3         | 3/3         | 2/3           | 3/3           |
| F18  | 3/3         | 0/3         | 3/3           | 3/3           |
| all  | **20/39**   | **28/39**   | **21/39**     | **34/39**     |

F12 is the ambiguity control and F07b its scoreable form; excluding F12 the assigned arm is 25/36 on
DeepSeek and 34/36 on Luna.

## What the round establishes

**The benefit is not model-independent.** The pre-declared rule needed three of the four Luna gains
to reappear; one did.

- Gains on both models: F07b (+2/3 here, +2/3 on Luna), F06 (+2/3 here, +1/3 on Luna) and F17 (+3/3
  here, +1/3 on Luna). F06 and F17 reach the stable margin only on DeepSeek.
- Luna-only gains: F02, F09 and F11. DeepSeek's baseline already passes F02 and F09 at 3/3, so those
  cases carry no headroom here, and F11 moves only +1/3.
- DeepSeek-only losses: F18 falls from 3/3 to 0/3, and F01 from 2/3 to 1/3. The skill helps less on
  this model and costs it one case outright.

F18 is the case that keeps unsupported benchmark claims from looking verified. Under the pinned
meaning-based reading the assigned samples fail req3 (sample 1 does not name the missing throughput
baseline or the operator review record) and req1 with forbidden 2 (samples 2 and 3 call the p99
figure partially supported or an actual measurement while holding no checkable evidence). The
regrade removed an over-strict req4 reading and the failures stayed, so this is a real loss rather
than a judging artifact.

## Grading defects closed in this round

- F15 assigned: the first verdict file was truncated mid-JSON and parsed as a grading failure.
  Regraded at 1/3, with samples 1 and 3 asserting unreproduced race outcomes as observed fact.
- F18 assigned: the first verdict applied a stricter req4 than the pinned note, failing scope
  statements the note accepts. Regraded; req4 met for all three, the failures moved to req3 and
  req1/forbidden 2, and the case stays 0/3.
- F17 baseline: the grouped batch stalled after twelve verdicts. Cancelled and regraded on its own;
  the case is 2/3, which raises the Luna baseline total from the 19/36 the partial batch implied.

No criterion, fixture or pinned reading changed. All three defects are disclosed rather than
averaged away.

## Limits

- The two rounds do not share a judge: Luna samples were graded by DeepSeek Flash and DeepSeek
  samples by Luna. Cross-model deltas therefore carry judge variation; per-case comparisons inside
  one round are the sound ones.
- Each case has one batch of three samples. At this sample size a 1/3 move is not a result, which is
  why only the ≥ 2/3 moves above are treated as findings.
- The seven saturated cases and the F07 control were not sampled, so they remain regression guards
  carried from earlier rounds.
- DeepSeek ran at its default reasoning effort because the workflow fan-out exposes no effort
  option; the effort is recorded as unknown rather than assumed.

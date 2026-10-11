# Global 21-case round

The complete suite measured on the shipped body for both actor families and both arms, so every
case, including the ones earlier rounds only sampled once, has a three-sample result.

- Skill body: `2bac7a6688ba98fd26dfa2ef714f85571d3ee3408262e623a3de9eb5161d42aa` (1282 words).
- Actors: `deepseek-flash` and `gpt-6-luna`, three fresh samples per case and arm.
- Judges: cross-family, one grouped call per case and arm — Luna samples graded by `deepseek-flash`,
  DeepSeek samples by `gpt-6-luna`.
- Coverage: eight cases (F04, F05, F07, F10, F12b, F14, F16, F19) were sampled here for the first
  time; the other thirteen come from the rounds in
  [the Luna record](2026-10-11-luna-three-sample.md) and
  [the DeepSeek record](2026-10-11-deepseek-three-sample.md). The Luna thirteen were measured on
  `f7a6603e…`, which differs from the shipped body only by the non-instructional sources block that
  [SCORING.md](../SCORING.md) exempts from re-measurement; the DeepSeek thirteen and the eight new
  cases for both families were measured on the shipped body.
- One grading defect was closed: the first F19 baseline verdict was malformed and was regraded to
  0/3.

## Per-case results

`P` is a passing sample.

| case | role              | DS baseline | DS assigned | Luna baseline | Luna assigned |
| ---- | ----------------- | ----------- | ----------- | ------------- | ------------- |
| F01  | scored            | PP.         | P..         | PPP           | PPP           |
| F02  | scored            | PPP         | PPP         | ...           | PPP           |
| F03  | scored            | P.P         | PPP         | P.P           | PPP           |
| F04  | saturated         | P.P         | PPP         | PPP           | PPP           |
| F05  | saturated         | PPP         | PPP         | PPP           | PPP           |
| F06  | guard             | P..         | PPP         | .PP           | PPP           |
| F07  | ambiguity-control | ...         | PPP         | ...           | ...           |
| F08  | scored            | ..P         | PP.         | P..           | ..P           |
| F09  | scored            | PPP         | PPP         | .P.           | PPP           |
| F10  | saturated         | PPP         | PPP         | PPP           | PPP           |
| F11  | scored            | ...         | P..         | ...           | PPP           |
| F12  | ambiguity-control | P..         | PPP         | ...           | ...           |
| F13  | scored            | PPP         | PPP         | PPP           | PPP           |
| F14  | saturated         | PPP         | PPP         | PP.           | PPP           |
| F15  | scored            | .P.         | .P.         | PPP           | PPP           |
| F16  | saturated         | P.P         | P..         | .PP           | PPP           |
| F17  | scored            | ...         | PPP         | .PP           | PPP           |
| F18  | scored            | PPP         | ...         | PPP           | PPP           |
| F19  | saturated         | ...         | PPP         | PPP           | PPP           |
| F07b | scored            | ...         | PP.         | .P.           | PPP           |
| F12b | saturated         | PPP         | PPP         | .P.           | PPP           |

## Totals

| group                              | cases | cells | DS baseline | DS assigned | Luna baseline | Luna assigned |
| ---------------------------------- | ----- | ----- | ----------- | ----------- | ------------- | ------------- |
| all cases                          | 21    | 63    | 36          | **50**      | 38            | **55**        |
| excluding the ambiguity controls   | 19    | 57    | 35          | **44**      | 38            | **55**        |
| informative: scored plus the guard | 12    | 36    | 19          | **25**      | 21            | **34**        |
| saturated                          | 7     | 21    | 16          | 19          | 17            | **21**        |
| ambiguity controls                 | 2     | 6     | 1           | **6**       | 0             | 0             |

## What the round shows

- **Both families improve**, and the gain is largest where the case can move: DeepSeek 36/63 to
  50/63, Luna 38/63 to 55/63; on the informative twelve, DeepSeek 19/36 to 25/36 and Luna 21/36 to
  34/36.
- **The ambiguity controls are where the two families differ.** Their correct answer is no change at
  all. Luna fails all six cells in both arms, so the skill neither causes nor repairs its
  over-editing there; DeepSeek passes six of six with the skill against one of six without it. On
  this model the skill's clearest effect is that it stops edits the artifact did not need.
- **"Saturated" no longer describes the measured baselines.** The label came from rounds with one
  sample per case. At three samples the baseline fails five DeepSeek cells and four Luna cells in
  that group, and the assigned arm passes every Luna saturated case. The role column is therefore
  historical classification, not a live property; the measured rates above are what the suite
  reports.
- **One case inverts for DeepSeek**: F16 scores 2/3 without the skill and 1/3 with it. The two
  failing samples fold an unrelated ledger migration into the dated history and attribute one
  interval's source to another, which is the kind of added claim the skill exists to prevent.
- F08 stays weak on both families (2/3 DeepSeek, 1/3 Luna), and F15 does not move for DeepSeek.

## Limits

- Three samples per cell. One-sample moves are inside the measured judge band and are not treated as
  results; F07b, F09 and F16 have each moved by one sample between batches.
- The two families use the same cross-family judge pairing as the earlier rounds, so per-case
  comparisons inside a round are sound and cross-family deltas carry judge variation.
- This measures explicit skill-body exposure only: automatic skill discovery, real editing
  workflows, and other model tiers remain unverified.

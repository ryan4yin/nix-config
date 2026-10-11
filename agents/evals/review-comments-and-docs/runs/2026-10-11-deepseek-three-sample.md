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
- A judge reported a criterion-count conflict: the instruction said five forbidden criteria for
  F07b, which defines four. It emitted the four the case writes and said so in `notes`, which is
  correct. [SCORING.md](../SCORING.md) now says the task file's indices are the only ones to grade
  and that a judge never invents a missing index.
- A later grading of F07b failed every sample because its findings block contained text. Findings
  are required output and are not part of the artifact, so the verdict was void. The regrade
  restored 3/3. [SCORING.md](../SCORING.md) now states the artifact is the `<artifact>` block alone
  and that such a verdict is a grading defect to regrade.

No criterion, fixture or pinned reading changed. All three defects are disclosed rather than
averaged away.

## A DeepSeek-targeted revision, measured and not shipped

The weak DeepSeek cases were traced to three causes: a claim stated more strongly than its evidence
(an unsupported p99 figure called measured or partially supported, an unsynchronized access reported
as an observed lost count, a date mismatch reported as an established contradiction, an operational
reason invented for a comment); a correction that never reached the table cell stating the same
fact; and item-level scope mistakes (a wiki-musing TODO kept, a dated TODO converted into an undated
limitation). Four clauses were added to the body (`ae45e551…`, 1388 words, 106 more than the shipped
body) and the six weak cases were re-sampled three times for both actor families. The baseline arm
reads no skill, so its numbers stand.

| case | DS before | DS after | Luna before | Luna after |
| ---- | --------- | -------- | ----------- | ---------- |
| F01  | 1/3       | 1/3      | 3/3         | 3/3        |
| F07b | 2/3       | 3/3      | 3/3         | 2/3        |
| F08  | 2/3       | 2/3      | 1/3         | 2/3        |
| F11  | 1/3       | 2/3      | 3/3         | 3/3        |
| F15  | 1/3       | 3/3      | 3/3         | 3/3        |
| F18  | 0/3       | 0/3      | 3/3         | 2/3        |
| all  | 9/18      | 11/18    | 16/18       | 15/18      |

The revision was reverted under the rule fixed before the run, that no Luna case which was 3/3 may
drop, and the body stays at `2bac7a6688ba98fd26dfa2ef714f85571d3ee3408262e623a3de9eb5161d42aa` with
1282 words. Two points are recorded rather than smoothed over:

- Only the DeepSeek F15 move reaches the 2/3 margin this suite treats as a result. The other five
  moves, including both Luna drops, are single-sample moves inside the measured judge band, so this
  run shows a real gain on one case and no established loss while the pre-registered rule reads the
  Luna drops as a loss. The smaller, already-measured body was kept, and a future round may read the
  same numbers differently with more samples.
- The revision cost 106 words — the largest single addition so far — for that one case. Length is an
  independent reason to prefer the body that ships.

The Luna F07b drop still matters: one sample rewrote a byte-identical fixture, deleting the settings
table and replacing `restored` with `Returned`, which is the boundary that case exists to guard.

## A second attempt on the same cases: the status-label clause

The DeepSeek gap was then attacked one clause at a time instead of in a batch. The F18 failures
pointed at a mechanism: the report declared every claim unverified once, at the top, and then
repeated the note's own `measured on the staging benchmark` phrasing where it discussed the p99
figure, so each claim read as measured at the point the judge checked. Two wordings were measured on
DeepSeek's F18 and F15 plus Luna guards, three samples each; the baseline arm reads no skill and
does not move.

| body       | clause                                | DS F18        | DS F15        | Luna F18 | Luna F15 | Luna F07b                             |
| ---------- | ------------------------------------- | ------------- | ------------- | -------- | -------- | ------------------------------------- |
| `2bac7a66` | shipped, none                         | 0/3           | 1/3           | 3/3      | 3/3      | 3/3, and 3/3 again on a control batch |
| `f556ab77` | label each claim where you discuss it | 3/3           | 3/3           | 3/3      | 3/3      | 2/3, one sample rewrote the table     |
| `f2afa601` | the same clause plus a guardrail      | not collected | not collected | —        | —        | 0/3, all three rewrote the table      |

The first wording fixed DeepSeek's two worst cases, including the 3-sample F18 gap, at 53 words. It
also cost one Luna sample on the no-change boundary, which the pre-registered rule treats as a loss.
Because a single-sample move can be batch luck, the shipped body's F07b was sampled a second time as
a control: it came back 3/3, giving the shipped body two clean batches against one modified sample
in each edited body. The control turned the drop into a boundary loss rather than noise, so the
first wording was reverted too.

The second wording added a guardrail and made the boundary worse: all three Luna samples deleted the
settings table and rewrote it as prose. The guardrail was written as a prohibition — it told the
report rule never to turn a value's missing provenance into a defect and never to justify an edit —
which puts provenance defects and edits in the same sentence as the behaviour it means to prevent,
and every sample then did exactly that. This is the negation effect the `writing-for-agents` skill
names: a prohibition activates the material it forbids. A next attempt would have to steer this
clause with a positive target.

The line is closed at the shipped body
`2bac7a6688ba98fd26dfa2ef714f85571d3ee3408262e623a3de9eb5161d42aa` (1282 words), not retried: two
wordings that each fix DeepSeek's F18 and F15 and each cost the byte-identity boundary on Luna, with
a plausible causal path both times, is enough evidence that this clause trades one failure mode for
another at this length.

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

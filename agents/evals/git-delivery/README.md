# Git delivery fixtures

Read `fixtures.json` as the fixed input. For each fixture, ask for a commit message and a PR
description as if the diff and facts were the complete task record. Do not execute commands or edit
the fixture repository. Compare current and baseline skill arms with the same prompt and model; take
the baseline with `git show <rev>:agents/skills/git-delivery/<file>` into a scratch directory, and
run one fresh agent per fixture and arm. Keep `examples.md` free of the fixtures' changes, or the
run grades copying.

## Grading

Apply the `git-delivery` caps and repository conventions first. Then grade each artifact on these
criteria:

- F1 bump: subject only. Keep the fix's purpose in the subject if it fits; omit historical test
  results and the untested platform.
- F2 restructure: subject-only commit. PR description uses readable paragraphs or bullets, states
  why the breadth is needed and where review should start, and mentions the shared activation guide.
  Keep table counts and formatter churn only if useful to reviewer assessment.
- F3 state-clear: body names the deleted pending jobs and the database-retained jobs, plus the
  required drain-before-restart effect. Keep investigation history out; use `Refs`, not `Fixes`.
- F4 build-rule: subject only. The effect is visible; placement rationale goes in the PR if useful.
- F5 commit-reference: body records restored pending-job retention and unrecoverable prior
  deletions; cite `1a2b3c4` and its subject in the repository format.
- F6 format-migration: PR description explains reader-before-writer rollout and rollback order, the
  cache-warming risk, and no production rollout. Keep commit body within the invisible-effect rule.

For all fixtures, report subject characters, body sentences and words, and PR-description words,
measured by a script rather than taken from the model's own report; apply the same caps to both
arms. Check that independent review points are visually separated in the PR description without
exceeding the caps. Passing means both arms follow the fixed placement criteria and the new arm does
not lose any required fact; shorter output alone does not pass.

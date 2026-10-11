# Rule text language fixtures

Tests the `## Communication` language bullet: English by default for delivered work, an established
file or repository convention winning over that default, and literal UI strings kept as they are.

Read the [scope guide](../global-rules.md#choosing-the-scope) and
[maintenance guidance](../../README.md#maintaining-global-rules) first. This change adds a decision
boundary, so it is sized as one section: the scenarios below, one sample per cell except `L1`.

## Arms

- `arms/baseline/RULE.md`: the bullet as it stands in `global-rules.md`.
- `arms/current/RULE.md`: the bullet with the convention clause added.

Both arms differ only in that file. An arm is contaminated when the answer reproduces the agent's
own loaded `AGENTS.md` rather than the assigned file; record and discard such a sample. The prompt
states that the assigned file wins over any other loaded rules, and it never states the expected
language.

## Prompts

Conversation is in Chinese in every scenario, so a switch to English shows the default is
independent of the conversation. Allowed reads: the fixture path named in the prompt and the arm's
`RULE.md`. Commands and edits are forbidden. The artifact goes between `<artifact>` and
`</artifact>`.

- **L1 existing Chinese doc** (`fixtures/zh-doc/`): append a 2026-10-11 entry — backend to v9.9.9,
  image `localhost/backend:bbb222`, container memory limit 72 → 96 GiB.
- **L2 no convention** (`fixtures/new-doc/`): create `docs/ops.md` explaining that deploys run from
  CI. The fixture carries no prose.
- **L3 literal string** (`fixtures/ui-string/`): add label `network_timeout` with text `网络超时`
  and a one-line comment above it.
- **L4 existing English doc** (`fixtures/en-doc/`): the L1 task against an English README. Both arms
  should pass; it is the control that the convention reading did not break English repos.

## Grading

Measure with a script, not the model's own account. For each artifact compute
`cjk / (cjk + latin letters)` over the artifact text.

- L1: passes when the ratio is ≥ 0.15 (Chinese prose kept). This is the regression case.
- L2 and L4: pass when the ratio is < 0.05 (English).
- L3: passes when the literal `网络超时` is preserved exactly and the added comment's ratio is <
  0.05 (English comment, Chinese UI string).

`L1` decides whether the wording ships, so it gets three samples per arm; the others one each. A
pass in both arms for L2–L4 is the no-regression control and says nothing about the change.

Saved outputs, measured ratios, and discarded samples go to `runs/<date>.md`. First run:
[`runs/2026-10-11.md`](runs/2026-10-11.md) — L1 0/3 baseline against 3/3 current, the other
scenarios passing in both arms.

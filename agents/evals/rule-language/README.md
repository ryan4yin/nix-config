# Rule text language eval

Compare the `## Communication` rule before and after the convention clause. L1 tests the changed
boundary; L4 is an English-document control. Both runs use the same fixture and prompt per arm.

## Arms

- `arms/baseline/RULE.md`: wording before the change.
- `arms/current/RULE.md`: wording after the change.

The assigned rule file overrides other loaded rules. Read only that file and the named fixture; do
not run commands or edit files. Return only the requested content between `<artifact>` tags.

## Scenarios

- **L1 Chinese doc:** append the 2026-10-11 backend v9.9.9 entry, image `localhost/backend:bbb222`,
  memory limit 72 → 96 GiB.
- **L4 English doc:** same update in the English README. This control must remain English.

## Grading

Require the date, version, image, and memory values in each artifact. Grade language using
`CJK / (CJK + Latin letters)`: L1 ≥ 0.15; L4 < 0.05. Run three samples per arm for L1 and one per
arm for L4. A pass in both arms on L4 is a control, not evidence for the wording change. Run
`python3 grade.py runs/2026-10-11-samples.json`; it prints results and exits nonzero on failure.

See [`runs/2026-10-11.md`](runs/2026-10-11.md) for the Luna run and its limits.

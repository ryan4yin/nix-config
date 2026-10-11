# Throttle contract (authoritative)

`throttle(delay_ms, ceiling)`:

- A ceiling of zero disables the throttle and returns 0.
- A negative `ceiling` or a negative `delay_ms` raises `ValueError`. This is the contract the
  dispatch tests assert (`tests/test_throttle.py::test_negative_inputs_raise`).
- Otherwise the return is `min(delay_ms, ceiling)` in milliseconds.

The docstring in `F14-throttle.py` predates this contract and was not updated when the negative
input behavior changed.

## Upstream and workaround

Upstream issue edge-systems/dispatch#88 (the broker rejects a zero ceiling instead of treating it as
disabled) and the workaround reason are recorded locally in `F14-upstream-88.md`; that file is the
authority for the comment in `F14-throttle.py`.

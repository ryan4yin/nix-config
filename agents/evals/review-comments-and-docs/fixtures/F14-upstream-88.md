# Upstream issue 88 — broker mishandles a zero ceiling

- Upstream: edge-systems/dispatch issue #88, "broker mishandles a ceiling of 0 instead of treating
  it as disabled".
- Local reproduction 2026-08-30 on broker 4.2.1: a ceiling of 0 returned `400 invalid ceiling`.
- Workaround in `throttle`: resolve the zero-disable case locally and return 0 before doing the
  ordinary broker-compatible `min(delay_ms, ceiling)` calculation for nonzero ceilings.
- Removal condition: drop the local zero branch once the broker fix ships, and update the comment in
  `F14-throttle.py` at that time.

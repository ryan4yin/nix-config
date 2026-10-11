# Exposure interval review record — observatory rig

- The sensor firmware locks the timing reference at 1.000 Hz; only the derived exposure interval is
  configurable.
- 2026-09-18: a power cycle reset the controller to its factory interval of 40 s. That day's
  settings screen was photographed to `photos/settings-2026-09-18.jpg` and shows 40 s. The
  photograph predates the changes below.
- 2026-09-21: the interval was re-applied and verified at 41 s: controller readback 41.0 s, 2 h soak
  with zero dropped frames.
- 2026-09-24: 42 s was entered and saved in the controller. On the next boot the controller
  auto-reverted the value to 41 s; the readback after the revert is 41.0 s. The 42 s value was never
  active for a capture run.

# Log index for build-node-02

- 2026-09-28: 1.17 V soak, `RESULT: PASS`, 6 h, recorded in `soak/2026-09-28.log`.
- 2026-10-01: the only surviving artifact is `photos/bios-2026-10-01.jpg`, a photograph of the setup
  screen showing 1.32 V. There is no POST log, no BMC event, and no OS boot log for that date.
  Whether the screen was saved before the machine was left is not recorded anywhere.
- 2026-10-02 onward: normal 1.17 V operation, logs present.

Retention note: the serial capture starts at POST. A session that never reaches POST leaves no
capture file, and a setup session that is abandoned without saving also leaves none. The two cases
are indistinguishable from the log index alone.

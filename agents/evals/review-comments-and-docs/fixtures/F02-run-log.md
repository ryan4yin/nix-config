# Raw run log index — render-node-03 voltage trials

Extracted 2026-10-02 from the BMC serial capture. Each entry is the run header line.

- 2026-09-13 21:40 UTC, `vdd2=1.15V`, y-cruncher v0.8.5, `RESULT: PASS`, duration 6 h 02 min, 0
  WHEA, 0 MCE. The capture ends with the line `run complete`.
- 2026-09-14 22:05 UTC, `vdd2=1.17V`, y-cruncher v0.8.5. The capture's last line is
  `00:21:04 elapsed 21 min`, then the serial capture stops. There is no PASS line. A hand note in
  the capture reads "box frozen, hard reset".

The two runs were captured separately; the 2026-09-13 run finished before the 2026-09-14 run began.

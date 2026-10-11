# Trial conditions — render-node-05

- 2026-09-20 14:10 UTC: 1.15 V, y-cruncher 20 min at 100% load, ambient 19 °C, chassis fan forced to
  100%. Result: PASS. No isolated IMC, VRM, or DIMM temperature was measured; only a single
  package-level reading at the end of the run is retained.
- 2026-09-27 02:40 UTC: 1.17 V, y-cruncher 20 min at 100% load, ambient 24 °C, fan stopped. Result:
  FAIL (the log ends at 21 min). No isolated component temperature was measured.
- One run per condition. Voltage, wall-clock time, and ambient differ between the two runs, so the
  fan state is not the only variable.
- The BMC event log for both runs contains no power-supply fault entries. Other error classes were
  not reviewed, and no supply-rail measurement was taken.

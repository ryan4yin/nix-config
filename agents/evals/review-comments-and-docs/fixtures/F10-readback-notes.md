# Readback labeling notes — build-node-03

- The setup screen prints a voltage next to the field `CPU VDDIO / MEM VDDIO`, but this BIOS
  revision does not document which rail that field reads. The board manual labels the pad only as
  "unassigned test point".
- The field returned `Auto (1.280 V)` on 2026-10-03 and also on 2026-09-29. Those two reads are the
  only observations of it.
- The 1.104 V value belongs to the separate `CPU VDDCR_SOC` field and is not the same reading.
- No tool available on the node attributes board readbacks to rails.

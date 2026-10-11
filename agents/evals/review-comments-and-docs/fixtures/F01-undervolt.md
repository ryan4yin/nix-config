# CPU VDD2 tuning log — build-node-01

## Summary

The recent tuning pass ended in a no-POST at 1.30 V, so the node is back on the earlier voltage
while we decide what to try next.

## Setting table

| Setpoint | State                 | Outcome                |
| -------- | --------------------- | ---------------------- |
| Auto     | applied               | baseline, stable       |
| 1.30 V   | applied then reverted | no POST at 1.30 V      |
| 1.17 V   | applied               | soak passed 2026-09-14 |

## Notes

- 2026-09-12: entered 1.30 V in BIOS setup and reverted before saving. That setting was never booted
  or tested, so there is no observed outcome for it.
- 2026-09-14: set 1.17 V and ran the soak; the BIOS readback shows 1.168 V. The run completed
  without a crash.

## Conclusion

1.30 V is unusable on this board because it does not POST; keep the current 1.17 V setpoint.

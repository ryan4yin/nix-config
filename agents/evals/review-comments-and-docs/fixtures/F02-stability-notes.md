# Voltage stability notes — render-node-03

Everything below is inference from board behavior; nothing has been stress-tested on this board, so
treat the whole table as provisional.

| Setpoint | Result                 | Basis                     |
| -------- | ---------------------- | ------------------------- |
| Auto     | baseline               | vendor default            |
| 1.15 V   | froze after about 20 m | 2026-09-13 y-cruncher run |
| 1.17 V   | passed a 6 h soak      | 2026-09-14 y-cruncher run |

## Dated notes

- 2026-09-13: y-cruncher at 1.15 V. The log ends when the machine froze; no WHEA events were
  recorded before the freeze.
- 2026-09-14: 6 h soak at 1.17 V completed with no WHEA events.

## Conclusion

Since nothing was actually tested, the table is a set of inferences; the 1.17 V pass is the only
reason to keep that setpoint.

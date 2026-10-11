# IMC thermal investigation — render-node-05

## Conclusion

The fan test proves the freezes are an IMC thermal problem. The later fan-failure run excludes
temperature as a factor, because the machine failed with the fan off too.

## Trials

### 2026-09-20 — fan forced to 100%

One 20-minute y-cruncher pass at 1.15 V with the chassis fan forced to 100%. The run passed, so the
IMC was overheating before.

### 2026-09-27 — fan stopped

One 20-minute y-cruncher pass at 1.17 V with the fan stopped. The machine failed, so temperature was
not the cause.

## Power

No errors were logged during either trial, so the PSU is ruled out.

## Next

Rerun both trials at the same voltage to confirm.

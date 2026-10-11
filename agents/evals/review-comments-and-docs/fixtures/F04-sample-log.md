# Sample log excerpt — build-node-01 soak, 2026-09-29

Partial copy only. The sampler writes one temperature line every 5 s, and the excerpt below is an
incomplete copy, not the end of the run.

- 871 s: 58.9 C
- 876 s: 59.5 C

Operator note: the 1.15 V soak was stopped by hand later, for an unrelated lab booking, so the run
was still recording after the last retained sample. The PASS marker cited by the summary comes from
the `2026-09-29b` capture, a separate run started after this one. The sampler records sample times,
not the stop time, and 59.5 C is simply the largest retained 5-second sample.

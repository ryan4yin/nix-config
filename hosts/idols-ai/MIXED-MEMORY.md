# Mixed memory on idols-ai

128G from JUHOR 2×48G + GLOWY 2×16G. All four DIMMs are needed because 96G is insufficient.

## Target configuration

This is the settled configuration for normal use. It passed a **6-hour 100G stress test with 0
errors** (highest sampled memory temperature: **56.8°C**) and then **29.6 hours of daily use over
two nights and one workday**, displays on and off, LLM serving throughout. Keep these settings
rather than increasing voltage further.

| Field                   | Target                    |
| ----------------------- | ------------------------- |
| XMP                     | Disabled                  |
| Gear mode               | Gear2                     |
| Memory speed            | 4800 MT/s                 |
| CPU VDD2                | **1.17 V fixed**          |
| VCCSA                   | Auto (BIOS reads 1.288 V) |
| DRAM VDD                | **1.28 V fixed**          |
| DRAM VDDQ               | **1.28 V fixed**          |
| DRAM VPP                | Auto (1.8 V)              |
| tCL / tRCD / tRP / tRAS | 40 / 40 / 40 / 77         |

## Hardware

- CPU: Intel Core Ultra 7 270K Plus.
- Board: Colorful CVN Z890 ARK FROZEN V20, BIOS 1013.
- Each channel: 48G (2R) in DIMM0, 16G (1R) in DIMM1.
- The 16G pair was added on 2026-10-06.

| Kit   | Capacity | XMP rating | Timings       | Voltage | Rank | Part number           |
| ----- | -------- | ---------- | ------------- | ------- | ---- | --------------------- |
| JUHOR | 2×48G    | DDR5-5600  | CL46-45-45-90 | 1.25 V  | 2R   | `JHE5600U4648JG`      |
| GLOWY | 2×16G    | DDR5-6400  | CL32-38-38-90 | 1.35 V  | 1R   | `VGM5UH64C32AG-DTACW` |

## Bring-up and recovery

Earlier attempts starting with the 48G pair or all four DIMMs did not reach BIOS. Working order:

1. Install only the 2×16G in `ChannelA-DIMM1` / `ChannelB-DIMM1`.
2. Enter BIOS and disable XMP.
3. Power off and add the 2×48G in DIMM0.
4. Allow 1 to 3 minutes for retraining, possibly with several reboots.
5. Apply the target settings above.

If failed training prevents BIOS entry, repeat this order; clear CMOS first if necessary. Failed
training can silently restore defaults; re-check settings in BIOS afterwards.

## Test results

Earlier DRAM tests used CPU VDD2 Auto (BIOS reading 1.104 V). **Bold values identify the rails
changed in each test.**

| CPU VDD2   | DRAM VDD                 | DRAM VDDQ                | Result                                                       | Highest sampled memory temperature |
| ---------- | ------------------------ | ------------------------ | ------------------------------------------------------------ | ---------------------------------- |
| Auto       | **1.10 V**               | **1.10 V**               | Immediate freezes during memory tests, even 4G.              | Not recorded                       |
| Auto       | **1.25 V**               | **1.25 V**               | 8G / 32G / 100G short tests passed; llama.cpp load froze.    | Not recorded                       |
| Auto       | **1.28 V**               | **1.28 V**               | 100G short test passed; daily use froze twice on 2026-10-08. | Not recorded                       |
| Auto       | **1.282 V**              | **1.282 V**              | Display corruption in BIOS.                                  | Not recorded                       |
| Auto       | **1.29 / 1.30 / 1.32 V** | **1.29 / 1.30 / 1.32 V** | Each setting failed training.                                | Not recorded                       |
| **1.13 V** | 1.28 V                   | 1.28 V                   | BIOS normal; no long test.                                   | Not recorded                       |
| **1.15 V** | 1.28 V                   | 1.28 V                   | 100G, 15 minutes: PASS.                                      | 45.5°C*                            |
| **1.15 V** | 1.28 V                   | 1.28 V                   | Long test froze; last saved duration: 21 minutes 17 seconds. | 56.5°C                             |
| **1.17 V** | 1.28 V                   | 1.28 V                   | 100G, **6 hours: PASS**.                                     | **56.8°C**                         |
| **1.17 V** | 1.28 V                   | 1.28 V                   | **2 nights + 1 workday: no freeze**, displays on and off.    | Not recorded                       |
| **1.20 V** | 1.28 V                   | 1.28 V                   | BIOS display corruption and freeze within 10 to 20 seconds.  | Not recorded                       |

*The 15-minute test used sparse temperature samples; its true peak is unknown. Long tests sampled
about every 5 seconds and used a 60°C stop threshold.

Both recent long tests were on 2026-10-09:

- At 1.15 V, the last record was at 01:02, with machine uptime of 1 hour 53 seconds. The saved
  durations are lower bounds, not exact freeze times.
- At 1.17 V, the test ran from 01:29 to 07:30, with 0 errors or hardware incidents and no swap use.
  Recorded temperatures stayed below 60°C.

## Daily use

One unbroken boot, 2026-10-09 01:24 to 2026-10-10 07:02: the 6-hour test and a workday with the
displays on, then a night with them off. Load stayed high — 100G stress test, then continuous LLM
serving with the KV cache streaming from RAM — and occupancy stayed around 70% or more.

No machine check, hardware error, BUG, Oops, or GPU fall-off; no OOM or hung task; no log gap over
60 seconds. Sleep/wake is untested — displays off only blanks them. Occupancy and temperature were
not logged and the board has no EDAC counters, so an error would show up as a freeze or corruption,
not a count.

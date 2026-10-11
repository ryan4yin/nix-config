# Mixed memory on idols-ai

128G from JUHOR 2×48G + GLOWY 2×16G. All four DIMMs are needed because 96G is insufficient.

## Current configuration

CPU VDD2 is set to **1.17 V** (BIOS reads **1.168 V**). This is the best configuration tested so
far, but it still froze during daily use on 2026-10-11. Keep it for normal use for now; higher
tested VDD2 settings have not provided a stable alternative.

| Field                   | Setting                                      |
| ----------------------- | -------------------------------------------- |
| XMP                     | Disabled                                     |
| Gear mode               | Gear2                                        |
| Memory speed            | 4800 MT/s                                    |
| CPU VDD2                | **1.17 V fixed (BIOS reads 1.168 V)**        |
| VCCSA                   | Auto (BIOS reads 1.288 V)                    |
| VDD2_MV (BIOS label)    | Auto (BIOS reads 1.280 V)                    |
| DRAM VDD                | **1.28 V fixed**                             |
| DRAM VDDQ               | **1.28 V fixed**                             |
| DRAM VPP                | Auto (1.8 V)                                 |
| tCL / tRCD / tRP / tRAS | 40 / 40 / 40 / 77 (last photographed values) |

Voltage settings and readings come from BIOS and user reports, not OS measurements.

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
5. Apply the current settings above.

If failed training prevents BIOS entry, repeat this order; clear CMOS first if necessary. Failed
training can silently restore defaults; re-check settings in BIOS afterwards.

## Test results

CPU VDD2 entries below are BIOS settings: Auto read 1.104 V in the earlier DRAM tests; the 1.17 V
setting reads 1.168 V. These BIOS readings are not measurements during the OS tests.

| CPU VDD2   | DRAM VDD             | DRAM VDDQ            | Result                                                                                                 | Highest sampled DIMM temperature               |
| ---------- | -------------------- | -------------------- | ------------------------------------------------------------------------------------------------------ | ---------------------------------------------- |
| Auto       | 1.10 V               | 1.10 V               | Immediate freezes during memory tests, even 4G.                                                        | Not recorded                                   |
| Auto       | 1.25 V               | 1.25 V               | 8G / 32G / 100G short tests passed; llama.cpp load froze.                                              | Not recorded                                   |
| Auto       | 1.28 V               | 1.28 V               | 100G short test passed; daily use froze on 2026-10-08.                                                 | Not recorded                                   |
| Auto       | 1.282 V              | 1.282 V              | Display corruption in BIOS.                                                                            | Not recorded                                   |
| Auto       | 1.29 / 1.30 / 1.32 V | 1.29 / 1.30 / 1.32 V | Each setting failed training.                                                                          | Not recorded                                   |
| 1.13 V     | 1.28 V               | 1.28 V               | BIOS normal; no long test.                                                                             | Not recorded                                   |
| 1.15 V     | 1.28 V               | 1.28 V               | 100G, 15 minutes: PASS.                                                                                | 45.5°C*                                        |
| 1.15 V     | 1.28 V               | 1.28 V               | Long test froze; last saved duration 21 min 17 s.                                                      | 56.5°C                                         |
| **1.17 V** | **1.28 V**           | **1.28 V**           | **100G, 6 hours: PASS, 0 errors or hardware incidents.**                                               | **56.8°C**                                     |
| 1.17 V     | 1.28 V               | 1.28 V               | About 56 hours across three boots ending cleanly; next boot froze during LLM serving (2026-10-11).     | 47.2°C in the last available monitoring sample |
| 1.20 V     | 1.28 V               | 1.28 V               | Earlier attempt: BIOS display corruption and freeze within 10 to 20 s.                                 | Not recorded                                   |
| 1.20 V     | 1.28 V               | 1.28 V               | 100G test froze with screen corruption; last saved duration 7 min 23 s (2026-10-11).                   | 55.25°C                                        |
| 1.18 V     | 1.28 V               | 1.28 V               | 100G test froze with screen corruption; last saved duration 14 min 36 s (2026-10-11).                  | 59.5°C                                         |
| 1.28 V     | 1.28 V               | 1.28 V               | Reached the desktop, then froze; journal spans 16:30:16 to 16:31:20 (64 s). No recorded pressure test. | Not recorded                                   |
| 1.30 V     | 1.28 V               | 1.28 V               | Set in BIOS only; rolled back without booting or testing.                                              | Not tested                                     |
| **1.17 V** | **1.28 V**           | **1.28 V**           | **100G, 15 minutes: PASS, 0 errors or hardware incidents (2026-10-11 17:29–17:45).**                   | **59.25°C**                                    |

*The 1.15 V short test used sparse temperature samples; its true peak is unknown. The monitored long
tests and the 2026-10-11 100G tests sampled about every 5 seconds with a 60°C stop threshold. Saved
durations are lower bounds on time before interruption, not exact freeze times.

The passing 1.17 V test ran on 2026-10-09 from 01:29 to 07:30 without swap use. Subsequent daily use
included displays on and off with LLM serving. Sleep/wake is untested.

The 1.17 V freeze on 2026-10-11 ended logging at 13:55:46, about 4 h 47 min after boot. Logs stopped
during generation without a shutdown sequence or a recorded machine check, BUG or Oops.

## BIOS limitations and conclusion

Attempts to apply tRFC 1180 and primary timings 42 / 42 / 42 / 82 reverted automatically after
saving, according to the user's BIOS checks. Those relaxed settings never became a tested
configuration. The memory frequency control is also locked at 4800 MT/s in the current BIOS setup.
The table above retains the last photographed timings; a later readback has not been recorded.

Keep CPU VDD2 at 1.17 V and DRAM VDD/VDDQ at 1.28 V for now. The passing stress test and daily-use
record make this the best tested option, but the later freeze means stability remains unresolved.

The user reports a possible ambient temperature rise of about 10°C. Temperature may affect the
remaining margin, but neither temperature nor an IMC, DIMM or motherboard fault has been isolated.
Manual timing relaxation and frequency reduction are currently unavailable; further tuning is
paused. Revisit only if freezes continue or those BIOS controls become usable.

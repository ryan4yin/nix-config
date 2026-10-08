# Mixed memory on idols-ai

128G from JUHOR 2×48G + GLOWY 2×16G. Four DIMMs are required because 96G is insufficient.

## Hardware

- CPU: Intel Core Ultra 7 270K Plus (Arrow Lake-S Refresh, LGA1851).
- Board: Colorful CVN Z890 ARK FROZEN V20, BIOS version 1013; four DDR5 slots, rated up to 192G.
- Layout: each channel has 48G (2R) in DIMM0 and 16G (1R) in DIMM1.
- The 16G pair was added on 2026-10-06. XMP is off; both kits run at 4800 MT/s.

| Kit   | Capacity | XMP rating | Timings       | Voltage | Rank | Part number           |
| ----- | -------- | ---------- | ------------- | ------- | ---- | --------------------- |
| JUHOR | 2×48G    | DDR5-5600  | CL46-45-45-90 | 1.25 V  | 2R   | `JHE5600U4648JG`      |
| GLOWY | 2×16G    | DDR5-6400  | CL32-38-38-90 | 1.35 V  | 1R   | `VGM5UH64C32AG-DTACW` |

## Bring-up and recovery

The working bring-up order starts with the 16G pair. Earlier attempts starting with the 48G pair or
all four DIMMs did not reach BIOS.

1. Install only the 2×16G in `ChannelA-DIMM1` / `ChannelB-DIMM1`.
2. Enter BIOS; set `内存模块资源 = 默认模块` (XMP off). DRAM voltage returned to 1.25 V.
3. Power off and add the 2×48G in DIMM0.
4. Allow retraining (1–3 minutes, possibly several reboots).
5. Set Gear2 and DRAM VDD/VDDQ to 1.280 V. The latest CPU VDD2 experiment uses 1.150 V.

If failed training prevents BIOS entry, repeat this order. If necessary, clear CMOS first.

## Current BIOS settings

`超频OC → 内存设置`, as of 2026-10-09. CPU VDD2 1.150 V passed BIOS checks and the 100G short test;
stability in daily use remains to be checked.

| Field                           | Setting / BIOS reading               |
| ------------------------------- | ------------------------------------ |
| `内存模块资源`                  | `默认模块` (XMP off)                 |
| `Gear选择`                      | Gear2                                |
| `内存频率(MHz)`                 | 4800                                 |
| `CPU VDD2电压`                  | **1.150 V fixed** / 1.152 V          |
| `VCCSA电压`                     | Auto / 1.288 V                       |
| `Vdd2Mv`                        | Auto / 1.280 V; meaning not verified |
| `Memory Voltage VDD`            | 1.280 V fixed                        |
| `内存电压VDDQ`                  | 1.280 V fixed                        |
| `内存电压VPP`                   | Auto / 1.800 V                       |
| `tCL` / `tRCD` / `tRP` / `tRAS` | 40 / 40 / 40 / 77                    |

`dmidecode` reports firmware-configured DIMM speed/voltage, not measured CPU VDD2 or VCCSA. Re-check
BIOS settings after failed training: the board can silently restore defaults.

## Voltage tests

Earlier DRAM tests used CPU VDD2 Auto (baseline BIOS reading 1.104 V). CPU VDD2 tests keep both DRAM
rails at 1.280 V. **Bold values are the parameters varied in each test.**

| CPU VDD2   | DRAM VDD                 | DRAM VDDQ                | Result                                                                                    | Highest sampled DIMM temperature |
| ---------- | ------------------------ | ------------------------ | ----------------------------------------------------------------------------------------- | -------------------------------- |
| Auto       | **1.10 V**               | **1.10 V**               | Immediate memory-test freezes, even 4G.                                                   | —                                |
| Auto       | **1.25 V**               | **1.25 V**               | 8G / 32G / 100G short tests passed; real llama.cpp load hard-froze.                       | —                                |
| Auto       | **1.28 V**               | **1.28 V**               | 100G short test passed; daily use still froze around 16:40 and after 23:00 on 2026-10-08. | —                                |
| Auto       | **1.282 V**              | **1.282 V**              | Reached BIOS, then display corruption.                                                    | —                                |
| Auto       | **1.29 / 1.30 / 1.32 V** | **1.29 / 1.30 / 1.32 V** | Each setting failed training.                                                             | —                                |
| **1.13 V** | 1.28 V                   | 1.28 V                   | BIOS operation normal; no long-term test.                                                 | —                                |
| **1.15 V** | 1.28 V                   | 1.28 V                   | 2026-10-09: 100G / 900.34 s PASS, exit 0, 0 hardware incidents, 0 errors.                 | 45.5°C*                          |
| **1.20 V** | 1.28 V                   | 1.28 V                   | BIOS display corruption and freeze within about 10–20 s; failed setting.                  | —                                |

*45.5°C is the highest of sparse samples during the run; the true peak is unknown. No temperature
record is available for the other tests. Future tests should sample periodically throughout the run.

DRAM 1.28 V is the best setting tried, but is confirmed unstable with CPU VDD2 Auto. The current
experiment changes only CPU VDD2 to 1.15 V to address those freezes. Keep VCCSA, Gear, frequency,
and DRAM rails unchanged. Do not repeat the failed 1.20 V CPU VDD2 setting.

Frequency changes and DIMM-removal experiments are excluded: this BIOS requires a profile that
rewrites many settings to change frequency, and the full 128G capacity is required.

## Stress testing

Save logs in persistent `~/tmp`; files directly under `~/` are ephemeral. Example 100G / 15-minute
run:

```bash
SP=$(nix build --no-link --print-out-paths nixpkgs#stressapptest)
set -o pipefail
stdbuf -oL -eL "$SP/bin/stressapptest" -s 900 -M 100000 -v 4 2>&1 | tee ~/tmp/memtest-100G.log
```

Pass requires exit 0, `Found 0 hardware incidents`, and `Status: PASS`. A short pass does not
establish stability in real workloads; earlier passing settings still hard-froze.

## Firmware-change checklist

BIOS changes can break LUKS TPM auto-unlock (PCR 0+7). After settings are final, re-enroll both
disks by partlabel; preserve the passphrase slot:

```bash
for d in /dev/disk/by-partlabel/disk-nixos-ai-root /dev/disk/by-partlabel/disk-data-datapart; do
  sudo systemd-cryptenroll --wipe-slot=tpm2 "$d"
  sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 "$d"
done
```

Secure Boot check: `sudo sbctl status`.

## Open items

- [ ] Check overnight and daily-use stability with CPU VDD2 1.150 V and DRAM VDD/VDDQ 1.280 V.
- [ ] After hard freezes, check for store/filesystem corruption:
      `nix-store --verify --check-contents --repair` and `btrfs scrub`.

# Mixed memory on idols-ai

Notes from adding a 2×16G kit to the existing 2×48G kit on this desktop.

## Hardware

### CPU

- Intel Core Ultra 7 270K Plus (Arrow Lake-S Refresh, socket LGA1851)
- 24 cores / 24 threads: 8 P-cores up to 5.5 GHz + 16 E-cores up to 4.7 GHz
- 36 MB L3, 40 MB L2, 125 W PL1 / 250 W PL2, 4-core Xe iGPU

### Motherboard

- Colorful CVN Z890 ARK FROZEN V20 (Intel Z890, LGA1851, ATX), BIOS version 1013
- 4× DDR5 DIMM slots, officially up to 192 GB (48 GB max per slot), DDR5-8400(OC) and slower

### Memory

| Kit   | Capacity | XMP rating            | Timings       | Voltage | Rank | Part number           |
| ----- | -------- | --------------------- | ------------- | ------- | ---- | --------------------- |
| JUHOR | 2×48G    | DDR5-5600 (PC5-44800) | CL46-45-45-90 | 1.25 V  | 2R   | `JHE5600U4648JG`      |
| GLOWY | 2×16G    | DDR5-6400 (PC5-51200) | CL32-38-38-90 | 1.35 V  | 1R   | `VGM5UH64C32AG-DTACW` |

- When they went in: the 2×16G GLOWY kit was added 2026-10-06; the 2×48G JUHOR kit was already in
  place when the platform was rebuilt 2026-04-27 (before that the host was an MSI LGA1700 board with
  an i5-13600KF — see the `hosts/README.md` inventory notes).
- Channel A/B, DIMM0 = 48G (2R), DIMM1 = 16G (1R) → 64G per channel, 128G total.
- With XMP off both kits run at JEDEC DDR5-4800; the board exposes one XMP profile per kit
  (`XMP 模块一` / `XMP 模块二`, XMP profile 1 / profile 2).

## Bring-up order (install the 16G pair first)

The order is mandatory. Starting from the 2×48G, or from all four DIMMs, does not POST: no BIOS
entry and nothing to change in setup — pull the 48G pair and start from step 1.

1. Insert **only the 2×16G**, in the board's primary slots (the first-populate pair the manual
   marks; the working layout has them in `ChannelA-DIMM1` / `ChannelB-DIMM1`).
2. Boot to BIOS; confirm `内存模块资源 = 默认模块` (memory module source = default module, i.e. XMP
   off) — the DRAM voltage comes back at 1.25 V.
3. Power off, then insert the **2×48G** in the remaining slots.
4. Boot; the board retrains once (1–3 min, possibly a few reboots), then works.
5. Last step: back in BIOS, set `Gear选择` (Gear mode) to `Gear2` and raise `Memory Voltage VDD` and
   `内存电压VDDQ` from 1.25 V to `1.28 V`. Leave every other setting alone. 1.29 V and up do not
   train.

Resulting layout: `ChannelA/B-DIMM0` = 48G (2R), `ChannelA/B-DIMM1` = 16G (1R).

## Working configuration

- `stressapptest` 8G / 32G / 100G all PASS at both 1.25 V and 1.28 V.

Current BIOS settings (`超频OC → 内存设置`, the Overclocking → Memory settings page). The BIOS was
used in Chinese; the English in the table translates those labels and is not the firmware's own
English wording:

| Field                                   | Value                                |
| --------------------------------------- | ------------------------------------ |
| `内存模块资源` (memory module source)   | `默认模块` (default module, XMP off) |
| `Gear选择` (Gear mode)                  | `Gear2`                              |
| `内存频率(MHz)` (DRAM frequency)        | `4800`                               |
| `CPU VDD2电压` (CPU VDD2 voltage)       | `1.104 V` (Auto)                     |
| `VCCSA电压` (VCCSA voltage)             | `1.288 V` (Auto)                     |
| `Vdd2Mv`                                | `1.280 V` (Auto)                     |
| `Memory Voltage VDD`                    | **`1.280 V`** (fixed)                |
| `内存电压VDDQ` (DRAM VDDQ voltage)      | **`1.280 V`** (fixed)                |
| `内存电压VPP` (DRAM VPP voltage)        | `1.800 V` (Auto)                     |
| `Primary Timing` `tCL` / `tRCD` / `tRP` | `40` / `40`                          |
| `Primary Timing` `tRAS`                 | `77`                                 |

The only hand-set voltages are the two DRAM rails, `Memory Voltage VDD` and `内存电压VDDQ`, both
**1.280 V** (not `Auto`) — this is what `dmidecode` reports as `Configured Voltage: 1.28 V`. These
four DIMMs only train up to 1.28 V: 1.29 / 1.30 / 1.32 V all fail training.

Confirm a BIOS change actually applied:

```bash
sudo dmidecode -t memory | grep -E 'Locator|Size|Rank|Speed|Configured Voltage'
```

## Stress testing

`script` block-buffers its log (use `-f`), and `/home/ryan` is tmpfs, so log to `~/tmp`:

```bash
SP=$(nix build --no-link --print-out-paths nixpkgs#stressapptest)
stdbuf -oL -eL "$SP/bin/stressapptest" -s 300 -M 32000 -v 4 2>&1 | tee ~/tmp/memtest-32G.log
```

Pass = exit 0 + `Found 0 hardware incidents` + `Status: PASS`. Escalate 8G → 32G → 100G → overnight.

## What does not work

- **XMP @ 5600 with 4 DIMMs**: the board never reaches BIOS. It can be a failed training, or
  training passing (the debug LED settles on **white** or **green**) with the hang on the
  display/iGPU side. Two stuck modes were seen: (1) the logo screen (`Del`/`F11`) with a white LED,
  then a hang; or (2) a black screen on the green LED. In every case there is no BIOS entry and the
  recovery is the same.
- Intel/JEDEC validate two DIMMs per channel well below 4800 (2DPC dual-rank ≈ 4400 or lower), so
  4800 is already above spec. 5600 needs two DIMMs (1DPC).

## Recover a non-POSTing board

All of the above — a failed training, the logo screen with a white LED, or a black screen on the
green LED — can leave no BIOS entry. The recovery is the same in every case: redo the **bring-up
order** above (pull the 48G pair, boot on the 16G pair with XMP off, then re-add the 48G pair). If
BIOS is still unreachable, clear CMOS and repeat.

## Firmware-change checklist

LUKS TPM auto-unlock (PCR 0+7) breaks on every BIOS change. Re-enroll both disks **by partlabel**,
after all BIOS changes are final:

```bash
for d in /dev/disk/by-partlabel/disk-nixos-ai-root /dev/disk/by-partlabel/disk-data-datapart; do
  sudo systemd-cryptenroll --wipe-slot=tpm2 "$d"
  sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 "$d"
done
```

Keep the passphrase slot (never `--wipe-slot=all`). Secure Boot check: `sudo sbctl status`.

## Notes

- A hang that forces a reboot can corrupt the Nix store; it is a risk whenever memory is unstable or
  not thoroughly tested, which is why a full-RAM stress test matters. After any forced reboot run
  `nix-store --verify --check-contents --repair` and `btrfs scrub`.
- The board silently reverts to defaults on failed training, so re-check with `dmidecode`.
- A passing stress test is not proof either: the 1.25 V config passed 8G / 32G / 100G and still
  hard-froze under a real llama.cpp load — no kernel log, one BERT hardware-error record in
  firmware.
- Decision: keep the current 128G 4-DIMM config at 4800. The board supports at most 48 GB per slot,
  so larger modules are not an option.

## Open items

- [ ] Confirm stability overnight: an overnight `stressapptest` → `~/tmp/memtest-overnight.log`, or
      the real llama.cpp load run overnight
- [ ] `nix-store --verify --check-contents --repair` + `btrfs scrub`

# Workarounds & known gaps

Temporary workarounds, version pins, carried patches, and known gaps are collected here, grouped by
type, each with the condition under which it can be removed. Review the list periodically so
obsolete workarounds get rolled back instead of lingering.

## How to use

- **Adding** — a change that introduces a workaround, pin, carried patch, or known gap adds a row
  under the matching section below in the same PR, with a concrete **removal condition**.
- **Removing** — once the removal condition is met, delete the change and set `Status` to `removed`
  (mention the ID in the commit), or delete the row.
- **Reviewing** — re-evaluate rows whose `Revisit` trigger is due and refresh `Status`.

## Pins

A version or revision pinned for a reason that can go away.

| ID     | What & where                                                                                                                                                                 | Why                                                                                                                                                                                                                                   | Removal condition                                                                                                             | Added      | Revisit                    | Status |
| ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------------------- | ------ |
| WA-001 | smartctl_exporter pinned to upstream `6274decc`, which carries PR [#329](https://github.com/prometheus-community/smartctl_exporter/pull/329) — `overlays/smartctl-exporter/` | `/metrics` returns HTTP 500 once a device becomes readable after startup ([#305](https://github.com/prometheus-community/smartctl_exporter/issues/305), [#326](https://github.com/prometheus-community/smartctl_exporter/issues/326)) | Drop once nixpkgs provides a version containing the #329 fix                                                                  | 2026-10-03 | next nixpkgs bump          | active |
| WA-002 | `nixpkgs-2505` — `flake.nix`; consumer `home/base/tui/container.nix`                                                                                                         | `kubernetes-helm` regressed in newer nixpkgs                                                                                                                                                                                          | Drop the input and its consumer once helm works again in current nixpkgs                                                      | 2025-12-03 | when helm is revisited     | active |
| WA-003 | `rust-overlay` follow — `flake.nix`                                                                                                                                          | lanzaboote v1.1.0's pinned rust-overlay uses the deprecated `stdenv.isLinux`/`stdenv.isDarwin`                                                                                                                                        | Drop the follow once lanzaboote updates its pin (or we drop the lanzaboote pin)                                               | 2026-09-25 | on lanzaboote bump         | active |
| WA-004 | `catppuccin` on `main` — `flake.nix`                                                                                                                                         | `main` carries the nodejs→nodejs-slim deprecation fix, which is not in a release                                                                                                                                                      | Switch to a release tag once it includes the fix                                                                              | 2026-09-25 | on catppuccin release      | active |
| WA-005 | `tuios` input — `flake.nix`; `home/base/tui/tuios/`                                                                                                                          | nixpkgs lags behind upstream                                                                                                                                                                                                          | Use nixpkgs' `tuios` once it is recent enough                                                                                 | 2026-10-03 | on nixpkgs bump            | active |
| WA-006 | `nixpkgs-blender` — `flake.nix`                                                                                                                                              | Blender 5.2 LTS + CUDA/OptiX pin; keeps `just up` from triggering a full source rebuild                                                                                                                                               | Bump deliberately when needed; drop the pin if the current nixpkgs build is acceptable                                        | 2026-07-24 | deliberate                 | active |
| WA-007 | WeChat from `nixpkgs-master` — `hardening/bwraps/default.nix`                                                                                                                | newest builds; the pinned channel lags                                                                                                                                                                                                | Fall back to the stable channel once it has a good build                                                                      | 2026-10-03 | on nixpkgs bump            | active |
| WA-016 | Sherpa-ONNX 1.13.8 override and Nix CMake patches — `flake.nix`, `home/linux/gui/base/vinput/package.nix`                                                                    | Vinput pins Sherpa 1.13.4, which does not recognize the `openvino` provider; newer upstream source needs Nix-compatible dependency linking                                                                                            | Drop the override and carried patches once Vinput's Sherpa dependency is at least 1.13.8 and builds with upstream Nix patches | 2026-10-04 | on Vinput or Sherpa update | active |

## Workarounds

A setting that works around a bug or a hardware quirk.

| ID     | What & where                                                                                                              | Why                                                                     | Removal condition                                                                               | Added      | Revisit                                     | Status |
| ------ | ------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- | ---------- | ------------------------------------------- | ------ |
| WA-008 | Relaxed NVMe APST (`nvme_core.default_ps_max_latency_us=100000`) — `hosts/idols-ai/hardware-configuration.nix`            | the KINGBANK KP260 (DRAM-less QLC) froze on slow APST wake-ups          | Drop the override once kernel/firmware fixes or replacement hardware make default APST reliable | 2026-10-03 | watch NVMe timeout/reset/AER in the journal | active |
| WA-009 | USB-SATA bridge mitigations (`usbcore.autosuspend=-1`, `usb-storage.delay_use=10`) — `hosts/12kingdoms-youko/default.nix` | flaky JMicron JMS567 resets with UDMA-CRC and I/O errors                | Drop once the bridge/controller is replaced; the signal is smartctl CRC/media errors            | 2026-09-21 | on hardware change or CRC errors            | active |
| WA-010 | Insta360 Link USB reset on S3 resume — `hosts/idols-ai/default.nix`                                                       | the camera stays enumerated with a stalled UVC endpoint after resume    | Drop after the Insta360 firmware or the kernel `uvcvideo` fixes it                              | 2026-08-01 | on kernel or firmware change                | active |
| WA-011 | Kernel module blacklist (`esp4`, `esp6`, `rxrpc`) — `hardening/kernel-hardening.nix`                                      | attack surface for the Dirty Frag LPE (CVE-2026-43284 / CVE-2026-43500) | Kept as defence in depth; drop only if something needs those modules                            | 2026-10-03 | rarely                                      | active |

If WA-008 freezes recur, the fallback is to restore
`nvme_core.default_ps_max_latency_us=0 nvme_core.io_timeout=4294967295 pcie_aspm=off`; this is a
recovery procedure, not its removal condition.

## Known issues

A known limitation with no fix yet.

| ID     | What & where                                                                                   | Why                                                                                                                                                                                                                          | Removal condition                                                                                                        | Added      | Revisit                                | Status |
| ------ | ---------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | ---------- | -------------------------------------- | ------ |
| WA-012 | `muvm` (x86_64 apps/games via microVM) disabled — `hosts/12kingdoms-shoukei/apple-silicon.nix` | Apple Silicon's 16k page size means x86_64 apps need `muvm`; it is off because it does not build/run on nixos-apple-silicon yet ([nixos-apple-silicon#237](https://github.com/nix-community/nixos-apple-silicon/issues/237)) | Re-enable once `muvm` builds and works                                                                                   | —          | on nixos-apple-silicon or muvm updates | active |
| WA-015 | Darwin secret ownership — `secrets/darwin.nix`                                                 | Blanket `chown /etc/agenix/*` can override declared root ownership through symlinks; source concern, not a verified runtime leak                                                                                             | Verify consumers/runtime ownership, replace blanket ownership with explicit per-file ownership, and recheck target modes | 2026-10-03 | next Darwin activation review          | active |
| WA-017 | NPU inference for X-ASR — `home/linux/gui/base/vinput/`                                        | OpenVINO and the NPU plugin load and the daemon opens `/dev/accel/accel0`, but no profiling evidence confirms model computation on the NPU; `npu_busy_time_us` did not increase in the sample test                           | Remove once per-layer NPU profiling confirms execution on `ai`                                                           | 2026-10-04 | when model/provider changes            | active |

## WIP

An unfinished feature or gap.

| ID     | What & where                      | Why                                                                                                      | Removal condition                                                 | Added      | Revisit   | Status |
| ------ | --------------------------------- | -------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------- | ---------- | --------- | ------ |
| WA-013 | NixOS tests — `outputs/README.md` | tests rebuild custom packages (no private cache) and hosts need their own ssh host key to decrypt agenix | Resolve when a private cache exists and tests can run per-service | 2024-03-13 | quarterly | active |

## Related

- Security architecture, threat model and audit status: [SECURITY.md](./SECURITY.md).
- Unmerged **nixpkgs** PRs are carried via the `nixpkgs-patched` input and the
  [`.agents/skills/nixpkgs-patched`](./.agents/skills/nixpkgs-patched/SKILL.md) workflow (that input
  currently carries nothing; package-level carries are recorded under `Pins`).
- Routine version pins (colmena, agenix, disko, lanzaboote, haumea, home-manager, `nixpkgs-stable`,
  `nixpkgs-darwin`, …) are the versions in use, not workarounds, so they are not listed here.

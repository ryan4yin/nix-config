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

| ID     | What & where                                                                                                                                                                 | Why                                                                                                                                                                                                                                   | Removal condition                                                                      | Added      | Revisit                | Status |
| ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- | ---------- | ---------------------- | ------ |
| WA-001 | smartctl_exporter pinned to upstream `6274decc`, which carries PR [#329](https://github.com/prometheus-community/smartctl_exporter/pull/329) — `overlays/smartctl-exporter/` | `/metrics` returns HTTP 500 once a device becomes readable after startup ([#305](https://github.com/prometheus-community/smartctl_exporter/issues/305), [#326](https://github.com/prometheus-community/smartctl_exporter/issues/326)) | Drop once nixpkgs provides a version containing the #329 fix                           | 2026-10-03 | next nixpkgs bump      | active |
| WA-002 | `nixpkgs-2505` — `flake.nix`; consumer `home/base/tui/container.nix`                                                                                                         | `kubernetes-helm` regressed in newer nixpkgs                                                                                                                                                                                          | Drop the input and its consumer once helm works again in current nixpkgs               | 2025-12-03 | when helm is revisited | active |
| WA-003 | `rust-overlay` follow — `flake.nix`                                                                                                                                          | lanzaboote v1.1.0's pinned rust-overlay uses the deprecated `stdenv.isLinux`/`stdenv.isDarwin`                                                                                                                                        | Drop the follow once lanzaboote updates its pin (or we drop the lanzaboote pin)        | 2026-09-25 | on lanzaboote bump     | active |
| WA-004 | `catppuccin` on `main` — `flake.nix`                                                                                                                                         | `main` carries the nodejs→nodejs-slim deprecation fix, which is not in a release                                                                                                                                                      | Switch to a release tag once it includes the fix                                       | 2026-09-25 | on catppuccin release  | active |
| WA-005 | `tuios` input — `flake.nix`; `home/base/tui/tuios/`                                                                                                                          | nixpkgs lags behind upstream                                                                                                                                                                                                          | Use nixpkgs' `tuios` once it is recent enough                                          | 2026-10-03 | on nixpkgs bump        | active |
| WA-006 | `nixpkgs-blender` — `flake.nix`                                                                                                                                              | Blender 5.2 LTS + CUDA/OptiX pin; keeps `just up` from triggering a full source rebuild                                                                                                                                               | Bump deliberately when needed; drop the pin if the current nixpkgs build is acceptable | 2026-07-24 | deliberate             | active |
| WA-007 | WeChat from `nixpkgs-master` — `hardening/bwraps/default.nix`                                                                                                                | newest builds; the pinned channel lags                                                                                                                                                                                                | Fall back to the stable channel once it has a good build                               | 2026-10-03 | on nixpkgs bump        | active |
| WA-020 | `fcitx5-vinput` pinned to release tag `v2.4.0` — `flake.nix`; consumer `home/linux/gui/base/vinput/default.nix`                                                              | Tracks a release tag instead of a branch, so `just up` stays on that release                                                                                                                                                          | Bump to a newer release tag when its changes are wanted                                | 2026-10-04 | on vinput release      | active |

## Workarounds

A setting that works around a bug or a hardware quirk.

| ID     | What & where                                                                                                              | Why                                                                     | Removal condition                                                                               | Added      | Revisit                                     | Status |
| ------ | ------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- | ---------- | ------------------------------------------- | ------ |
| WA-008 | Relaxed NVMe APST (`nvme_core.default_ps_max_latency_us=100000`) — `hosts/idols-ai/hardware-configuration.nix`            | the KINGBANK KP260 (DRAM-less QLC) froze on slow APST wake-ups          | Drop the override once kernel/firmware fixes or replacement hardware make default APST reliable | 2026-10-03 | watch NVMe timeout/reset/AER in the journal | active |
| WA-009 | USB-SATA bridge mitigations (`usbcore.autosuspend=-1`, `usb-storage.delay_use=10`) — `hosts/12kingdoms-youko/default.nix` | flaky JMicron JMS567 resets with UDMA-CRC and I/O errors                | Drop once the bridge/controller is replaced; the signal is smartctl CRC/media errors            | 2026-09-21 | on hardware change or CRC errors            | active |
| WA-010 | Insta360 Link USB reset on S3 resume — `hosts/idols-ai/default.nix`                                                       | the camera stays enumerated with a stalled UVC endpoint after resume    | Drop after the Insta360 firmware or the kernel `uvcvideo` fixes it                              | 2026-08-01 | on kernel or firmware change                | active |
| WA-011 | Kernel module blacklist (`esp4`, `esp6`, `rxrpc`) — `hardening/kernel-hardening.nix`                                      | attack surface for the Dirty Frag LPE (CVE-2026-43284 / CVE-2026-43500) | Kept as defence in depth; drop only if something needs those modules                            | 2026-10-03 | rarely                                      | active |
| WA-017 | keyd right-hand modifier passthrough — `modules/nixos/desktop/peripherals.nix`                                            | keyd folds right Ctrl/Shift/Meta into their left keys                   | Drop once keyd or fcitx5 keeps right-hand modifiers distinct                                    | 2026-10-05 | on keyd bump                                | active |
| WA-018 | user-owned `~/.ssh/config` + disabled systemd ssh-proxy include — `home/base/tui/ssh.nix`, `modules/nixos/base/ssh.nix`   | bwrap exposes root-owned store files as `nobody`                        | Drop once sandboxes preserve store ownership                                                    | 2026-10-06 | when sandbox layout changes                 | active |
| WA-019 | programs.steam.extraCompatPackages = [ pkgs-x64.dwproton-bin pkgs-x64.proton-ge-bin ] — modules/nixos/desktop/gaming.nix  | ACE games fail on GE/mainline Proton, work with DW-Proton               | Drop once mainline or GE-Proton runs these games (GE-Proton#433)                                | 2026-10-07 | on Proton/GE bump                           | active |

If WA-008 freezes recur, the fallback is to restore
`nvme_core.default_ps_max_latency_us=0 nvme_core.io_timeout=4294967295 pcie_aspm=off`; this is a
recovery procedure, not its removal condition.

## Known issues

A known limitation with no fix yet.

| ID     | What & where                                                                                   | Why                                                                                                                                                                                                                                                                      | Removal condition                                                                                                             | Added      | Revisit                                | Status |
| ------ | ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------- | ---------- | -------------------------------------- | ------ |
| WA-012 | `muvm` (x86_64 apps/games via microVM) disabled — `hosts/12kingdoms-shoukei/apple-silicon.nix` | Apple Silicon's 16k page size means x86_64 apps need `muvm`; it is off because it does not build/run on nixos-apple-silicon yet ([nixos-apple-silicon#237](https://github.com/nix-community/nixos-apple-silicon/issues/237))                                             | Re-enable once `muvm` builds and works                                                                                        | —          | on nixos-apple-silicon or muvm updates | active |
| WA-015 | Darwin secret ownership — `secrets/darwin.nix`                                                 | Blanket `chown /etc/agenix/*` can override declared root ownership through symlinks; source concern, not a verified runtime leak                                                                                                                                         | Verify consumers/runtime ownership, replace blanket ownership with explicit per-file ownership, and recheck target modes      | 2026-10-03 | next Darwin activation review          | active |
| WA-016 | subscription rule snapshots — `modules/nixos/desktop/networking/mihomo/` (`rules_from:`)       | mihomo's `proxy-providers` imports proxies only, so the `rules` and `proxy-groups` a subscription ships with are dropped by the core; the generator re-imports them from a local YAML copy that has to be refreshed by hand when the provider changes its routing policy | Drop the snapshots once mihomo can import rules from a proxy-provider, or the providers publish their rules as rule-providers | 2026-10-04 | when mihomo gains rule import          | active |

## WIP

An unfinished feature or gap.

| ID     | What & where                      | Why                                                                                                                                                                               | Removal condition                                                 | Added      | Revisit   | Status |
| ------ | --------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------- | ---------- | --------- | ------ |
| WA-013 | NixOS tests — `outputs/README.md` | full-host tests still rebuild custom packages (no private cache) and need the host ssh key to decrypt agenix; the shared-firewall security-exporters VM test now runs in CI (KVM) | Resolve when a private cache exists and tests can run per-service | 2024-03-13 | quarterly | active |

## Related

- Security architecture, threat model and audit status: [SECURITY.md](./SECURITY.md).
- Unmerged **nixpkgs** PRs are carried via the `nixpkgs-patched` input and the
  [`.agents/skills/nixpkgs-patched`](./.agents/skills/nixpkgs-patched/SKILL.md) workflow (that input
  currently carries nothing; package-level carries are recorded under `Pins`).
- Routine version pins (colmena, agenix, disko, lanzaboote, haumea, home-manager, `nixpkgs-stable`,
  `nixpkgs-darwin`, …) are the versions in use, not workarounds, so they are not listed here.

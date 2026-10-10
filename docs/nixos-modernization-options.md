# NixOS Modernization — Options and Decision Record

> **Purpose:** let the maintainer decide, per candidate, whether it is worth adopting — by comparing
> it against what this repository does **today**. A plan derived from this file is only approved
> work once its card here says **adopt**.
>
> Researched against nixpkgs `nixos-unstable` on 2026-10-07. Option names and upstream wording are
> quoted from the module sources cited in each card.

## How to use this file

1. Read the card, not the plan.
2. Fill in **Decision** with one of:
   - **adopt** — replace the current mechanism; the matching plan task becomes approved work.
   - **watch** — not now; the card's _Trigger to adopt_ says what would change the answer.
   - **reject** — decide against, with a one-line reason, so it is not re-litigated.
3. Recommendations below are mine; they are inputs, not conclusions.

Ordering rule used throughout: a candidate earns a plan task only if it **replaces a mechanism this
repository already runs** or **unlocks a concrete need**. "It exists and is newer" is not enough.

---

# A. Host services and networking

## A1. Tailscale Serve instead of caddy vhosts

**Current:** one caddy instance on `youko` fronts 12 vhosts on `*.writefor.fun` by Host/SNI, with
two TLS chains — a private `ecc-ca` (only repo machines trust it) and a lego/Cloudflare DNS-01
wildcard for phone/TV clients — plus `file_server`, `header_up Host` (SigV4), a wildcard 404
fallback, and a root-readable Cloudflare token in agenix.

**Proposed:** `services.tailscale.serve` for the services whose only clients are tailnet devices.

**Pros:** certificates become automatic and every tailnet device trusts them (today a phone without
`ecc-ca` gets a certificate error); removes the Cloudflare token and the DNS-01 propagation
workaround from those services; access control moves from "IP trust zone" to tailnet identity/ACL,
which is exactly the limitation `SECURITY.md` records; `--tcp=<port>` can also expose raw TCP.

**Cons:** Serve routes by mount path on one name, or (via the nixpkgs module) as Tailscale Services
with `tcp:<port>` endpoints only — there is no Host/SNI vhost equivalent, so path-sensitive apps
(gitea, rustfs) and base-url assumptions are a problem; rustfs S3 is SigV4-signed on the Host header
and cannot move; `file_server` and the wildcard 404 have no equivalent; Android TV/Jellyfin/Immich
native apps do not run Tailscale; LAN-local traffic would detour through WireGuard/DERP.

**Reversibility:** high — caddy config stays until each vhost is deleted deliberately.

**Trigger to adopt:** only for admin-only UIs (grafana, prometheus, alertmanager, vmalert,
uptime-kuma, s3-console) and for LAN-only services whose clients are all repo machines.

**Recommendation:** **partial adopt** — migrate admin UIs only; keep caddy for immich, jellyfin,
rustfs, file server, and the 404 fallback. The bigger win is retiring the private-CA chain if every
LAN-only client can run Tailscale.

**Decision:** _pending_

## A2. systemd-resolved

**Current:** `services.resolved.enable` is set **nowhere**; hosts use dhcpcd or static config and
the default `/etc/resolv.conf`. Note `modules/nixos/base/networking/mdns.nix` already sets
`services.resolved.settings.Resolve.MulticastDNS = false` — currently inert, and it will activate
the moment resolved is enabled. mDNS itself is provided by avahi.

**Proposed:** `services.resolved.enable = true`, optionally with `DNSOverTLS`/DNSSEC and caching.

**Pros:** caching resolver, DoT/DNSSEC available, consistent stub across hosts, and the mDNS caveat
is already handled by the existing setting.

**Cons:** the LAN gateway `suzi` is a mihomo transparent proxy that **hijacks DNS to fake IPs that
are only routable through the proxy** — DoT/DoH on a host would bypass that hijack and break proxied
domains (the same reason `transmission.nix` deliberately resolves through real resolvers instead of
the host resolver). Hosts running mihomo (idols-ai, shoukei) are the sensitive ones. Also interacts
with the transmission network namespace and container DNS.

**Reversibility:** high (one option, one service restart).

**Trigger to adopt:** a host that has no dependency on suzi's DNS hijack, or after the proxy setup
changes.

**Recommendation:** **watch** — the fake-IP dependency makes this riskier than it looks.

**Decision:** _pending_

## A3. systemd-networkd instead of dhcpcd

**Current:** physical hosts use `networking.useDHCP` (dhcpcd script); VM hosts and MicroVM guests
use static config with `useDHCP = false`; the `br0` bridge on VM hosts is declared through
`systemd.network.netdevs/networks` already.

**Proposed:** `networking.networkd.enable = true` with `networking.networks`/`networkdOptions`.

**Pros:** declarative per-interface config, one implementation for stage 1 and stage 2, no dhcpcd
shell script in the path, and VM hosts already speak `systemd.network` for the bridge.

**Cons:** bigger blast radius than any other item — a mistake on a `br0` VM host cuts the guests and
possibly remote reachability; migration touches every DHCP host; behaviour differences around
lease/renew and DNS handling.

**Reversibility:** medium — reversible in config, but only if you can still reach the host.

**Trigger to adopt:** guest-only first, then a non-VM host with console access.

**Recommendation:** **watch**, guest-only experiment (plan 3, task 5).

**Decision:** _pending_

## A4. Native journald shipping instead of per-host scraping only

**Current:** metrics are centralised (node_exporter on the LAN IP, smartctl exporter,
VictoriaMetrics on youko); logs stay on each host.

**Proposed:** `services.journald.upload` on hosts → `services.journald.remote` on youko (both
supported; `services.journald.gateway` exposes a read API).

**Pros:** first-class systemd path, no promtail/filebeat/GELF sidecar, structured fields survive,
per-host logs searchable in one place.

**Cons:** new listening port and its firewall rule plus eval test; youko becomes the retention owner
(disk, rotation); upload failures are silent unless monitored; TLS configuration is on you to get
right.

**Reversibility:** high.

**Trigger to adopt:** when needing to correlate logs across hosts, or when the first host with a
missing-log incident shows up.

**Recommendation:** **adopt** (low risk, clear operational win).

**Decision:** _pending_

## A5. zram-generator instead of zramSwap

**Current:** a local module `modules/nixos/base/zram.nix` wraps `zramSwap` and adds sysctl tunings
(swappiness, readahead), disabled on idols-ai (disk swapfile) and memoryPercent-tuned on shoukei.

**Proposed:** `services.zram-generator.enable` with a `zram0` definition.

**Pros:** systemd-native unit generator, config expressed as data, upstream-maintained, no
NixOS-specific script.

**Cons:** your module couples zram presence to sysctl tunings — the migration must keep that logic
working when zram is off; two zram implementations are easy to have half-enabled during the change;
the gain over a working `zramSwap` is mostly cosmetic.

**Reversibility:** high.

**Trigger to adopt:** whenever the zram module is next touched anyway.

**Recommendation:** **watch** — no current pain; fold into the next zram change.

**Decision:** _pending_

## A6. nixos-facter instead of hand-written hardware-configuration.nix

**Current:** 8 hosts carry hand-written `hardware-configuration.nix` (plus deliberate per-host
quirks such as the NVMe APST workaround WA-008 and USB-SATA mitigations WA-009).

**Proposed:** `hardware.facter` from nixpkgs (nixos-facter-modules upstreamed), report generated on
the machine.

**Pros:** hardware changes (disk swap, new NIC, RAM) no longer require regenerating a file by hand;
consistent with `nixos-anywhere` provisioning.

**Cons:** the report must live somewhere (repo or machine) and be regenerated on hardware change;
defaults become less transparent than a file you can read in the diff; your deliberate deviations
(kernel params, module options) still live in host config, so only part of the file is replaced.

**Reversibility:** high.

**Trigger to adopt:** on a new host build, or when a hardware change forces a regeneration anyway.

**Recommendation:** **watch** — adopt on the next new host rather than retrofitting eight.

**Decision:** _pending_

## A7. attic self-hosted binary cache

**Current:** substituters are the two Chinese mirrors plus numtide's cache; a cachix endpoint exists
in the config but is unused.

**Proposed:** `services.networking.atticd` on youko.

**Cons:** another service to run, back up, and monitor on the host that already carries the most
state; keys and tokens become a security surface (`modules/base/nix.nix` treats substituter trust as
a boundary); it solves a problem (cache misses / CI egress) that is not currently reported as pain.
**Pros:** control over retention, faster cross-host reuse, no third-party dependency for private
artifacts.

**Reversibility:** high.

**Trigger to adopt:** measurably slow rebuilds across hosts, or a need to cache artifacts that
cannot go to a public cache.

**Recommendation:** **watch**.

**Decision:** _pending_

## A8. nix-servd and the non-root daemon features

**Current:** static `nix.buildMachines` (`modules/nixos/server/remote-building.nix`); plain-user is
deliberately not a trusted user; Nix 2.35 via `nixVersions.latest` (WA-023).

**Proposed:** `nix-servd` for scheduling, plus `auto-allocate-uids` and `local-overlay-store`
experimental features.

**Pros:** dynamic builder selection and health checks instead of a hand-maintained list; the
experimental features move toward running the daemon without root, consistent with the
no-trusted-user policy; `local-overlay-store` can cut store duplication for remote builds.

**Cons:** experimental features in a repo whose value is reproducibility; `nix-servd` is young;
misconfiguration shows up as flaky builds rather than a clean failure; benefit is unclear while the
current three-arch remote build setup works.

**Reversibility:** medium (builds can be re-pointed, but half-migrated builders are confusing).

**Trigger to adopt:** when the static builder list starts causing real friction.

**Recommendation:** **watch**.

**Decision:** _pending_

## A9. sched_ext (scx-loader)

**Current:** default kernel scheduler (EEVDF); desktop latency is not currently reported as a
problem.

**Proposed:** `services.scx-loader.enable` with an scx scheduler (kernel 6.12+; the desktop runs a
recent kernel).

**Pros:** a scheduler that can be swapped per workload, userspace-recoverable if it misbehaves,
active upstream development.

**Cons:** another daemon; scheduler changes can produce subtle latency/throughput regressions that
are hard to attribute; no measured problem to solve yet.

**Reversibility:** high (stop the service).

**Trigger to adopt:** a benchmark showing a win on the desktop, or a workload that needs it.

**Recommendation:** **watch**, easy to trial.

**Decision:** _pending_

---

# B. Boot, images, VMs

## B1. limine instead of systemd-boot + lanzaboote

**Current:** systemd-boot everywhere, except qemu guests (GRUB on `/dev/vda`) and idols-ai, where
lanzaboote provides Secure Boot with a `/etc/secureboot` (lzpt) bundle; the lanzaboote flake input
must track a rust-overlay follow (WA-003).

**Proposed:** `boot.loader.limine` — in nixpkgs, with `secureBoot`, `validateChecksums`,
`panicOnChecksumMismatch`, `biosSupport`, `maxGenerations`, graphical menu.

**Pros:** one bootloader for UEFI and BIOS (covers the qemu guests' GRUB case); Secure Boot without
the lanzaboote flake input and its rust-overlay pin (WA-003 disappears); checksum validation of
kernel and initrd; nicer menu.

**Cons:** different trust model — it signs **limine itself** and validates artifacts by checksum,
rather than shipping a firmware-verified UKI, so `SECURITY.md` and the threat model must be updated;
key enrollment is a manual firmware dance (Setup Mode + `sbctl enroll-keys`) and is the one change
in this repository that can leave a machine unbootable; the existing lzpt bundle may or may not be
reusable; less NixOS mileage than systemd-boot.

**Reversibility:** low on the physical desktop (firmware + ESP state), high on a VM.

**Trigger to adopt:** wanting one loader across BIOS/UEFI targets, or the lanzaboote pin becoming
actual maintenance pain.

**Recommendation:** **watch for the desktop, adopt on a disposable guest first** — the value is real
but it is the highest-risk item on this list.

**Decision:** _pending_

## B2. boot.uki / system.build.uki

**Current:** lanzaboote already produces and signs a UKI on idols-ai; other hosts boot
kernel+initrd.

**Proposed:** `boot.uki`.

**Pros:** standard UKI with `ukify` settings, single signed artifact, clear story for measured boot.

**Cons:** largely redundant where lanzaboote exists; adopting it interacts with B1 (who signs, who
validates); no benefit for hosts without Secure Boot.

**Reversibility:** medium.

**Recommendation:** **reject for now** — revisit together with B1.

**Decision:** _pending_

## B3. Declarative images with systemd-repart

**Current:** guest images come from the existing pipeline (nixos-generators / disko-based); k8s
guests are MicroVMs booting declared state images.

**Proposed:** `image.repart.enable` + `system.build.images.{qemu,raw-efi,raw,sd-card}`.

**Pros:** images become a declared output of the system rather than a separate generator; GPT layout
in `repart.d`; upstream direction; pairs with `nixos-anywhere` and vmspawn testing.

**Cons:** new subsystem with less mileage; the artifacts are consumed by `~/codes/k8s-gitops`, so
every change is a two-repo change; must prove boot and state-image compatibility before replacing
anything.

**Reversibility:** high (additive while the old pipeline stays).

**Trigger to adopt:** next time the image pipeline needs a change anyway.

**Recommendation:** **adopt as an additive experiment**, not a replacement.

**Decision:** _pending_

## B4. systemd-repart at boot (partition growth)

**Current:** manual partition sizing; no automatic growth.

**Proposed:** `boot.initrd.systemd.repart.enable`.

**Pros:** images and SD-card installs grow themselves; GPT-only and declarative.

**Cons:** another initrd-stage moving part; only useful once B3 or a disk-image workflow exists.

**Reversibility:** high.

**Recommendation:** **watch** — depends on B3.

**Decision:** _pending_

## B5. systemd-sysupdate (A/B updates)

**Current:** generation switching through `nixos-rebuild` + bootloader entries — already atomic and
rollbackable.

**Proposed:** `systemd.sysupdate.enable` with transfer definitions and a timer.

**Pros:** A/B image updates with signature verification.

**Cons:** duplicates functionality the generation model already provides; adds a second update path
and its own state; unclear what problem it solves here.

**Recommendation:** **reject**.

**Decision:** _pending_

## B6. Measured boot phases / FIDO2 credentials

**Current:** Secure Boot via lanzaboote; TPM2/FIDO2 initrd options are off, so boot is signed but
not measured into a policy.

**Proposed:** `systemd.tpm2.enable`, `systemd.tpm2.pcrphases.enable`,
`boot.initrd.systemd.tpm2.enable`, `boot.initrd.systemd.fido2.enable`.

**Pros:** PCR phases make boot-phase measurement usable for sealing policies; FIDO2 gives a physical
second factor for LUKS.

**Cons:** PCR policies must be re-sealed whenever the boot chain changes (kernel updates, bootloader
change B1), which converts an update into a maintenance event; CPU microcode/firmware updates can
invalidate sealed state.

**Reversibility:** medium.

**Recommendation:** **watch** — revisit after B1 is settled.

**Decision:** _pending_

## B7. systemd-vmspawn

**Current:** libvirt domains (generated XML) for qemu guests; MicroVMs for k8s guests.

**Proposed:** hand-written `systemd.services` calling `systemd-vmspawn` (`--network-bridge=br0`,
`--image-disk-type=`, `--coco=`, vTPM).

**Pros:** throwaway VMs in one command; boots the B3 images directly; confidential-computing
options; no libvirt stack.

**Cons:** no nixpkgs module and no `.vmspawn` unit type, so it is hand-written unit code; no
declarative state-image management (MicroVM keeps `{etc,var,home}.img` and MAC-pinned NICs); libvirt
stays for existing guests anyway.

**Reversibility:** high (delete the unit).

**Recommendation:** **adopt narrowly** — for testing B3 images only.

**Decision:** _pending_

---

# C. Repository tooling (low risk, no service impact)

## C1. Literal lint settings

**Current:** no `lint-url-literals`. **Proposed:** `nix.settings.lint-url-literals = "warn"` (plus
the short/absolute-path variants). **Pros:** catches deprecated literal syntax before it becomes an
error. **Cons:** warning noise on first run. **Recommendation:** **adopt**. **Decision:** _pending_

## C2. nix-unit

**Current:** hand-rolled `expr.nix`/`expected.nix` pairs run by `just test`. **Proposed:**
`nix-unit` alongside them. **Pros:** assertions on options, warnings, and thrown errors; clearer
failures. **Cons:** a second test runner and a migration that can silently lose coverage if pairs
are deleted early. **Recommendation:** **adopt additively**. **Decision:** _pending_

## C3. nix-fast-build

**Current:** serial evaluation in CI. **Proposed:** `nix-fast-build` over the eval tests and the
three host systems, reusing remote builders. **Pros:** parallel eval/build, no new CI infra.
**Cons:** one more tool in the Justfile; CI already gates merges. **Recommendation:** **adopt**.
**Decision:** _pending_

## C4. Cleanups (no decision needed)

WA-001 (smartctl pin) should be dropped once nixpkgs carries the upstream fix; the "nixfmt with
width 100" sentence in `AGENTS.md` should be checked against the formatter `just fmt` actually
resolves to. **Recommendation:** **adopt**. **Decision:** _pending_

## C5. jj

Personal workflow change only; no repository impact. **Recommendation:** out of scope. **Decision:**
_pending_

---

# D. Lab-only experimental group

The whole group shares one characteristic: upstream labels it experimental, and a mistake can
prevent boot or login. **Recommendation for the group: evaluate in a disposable guest (plan 3),
adopt individually only afterwards.**

| #   | Candidate                                              | Current                                      | Main pro                                                                | Main con                                                                                                                                                                     | Recommendation               |
| --- | ------------------------------------------------------ | -------------------------------------------- | ----------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| D1  | `system.etc.overlay.enable`                            | /etc generated by the perl activation script | /etc becomes an EROFS + overlay mount; foundation for an immutable /etc | upstream: _"This is currently experimental. Only enable this option if you are confident that you can recover your system if it breaks."_; every /etc writer must be audited | lab only                     |
| D2  | `systemd.sysusers.enable` / `services.userborn.enable` | `update-users-groups.pl`                     | removes the perl script; prerequisite for an immutable /etc             | experimental; uid/gid migration risk                                                                                                                                         | lab only                     |
| D3  | `system.etc.overlay.mutable = false`                   | writable /etc                                | truly immutable /etc                                                    | **blocked**: agenix writes `/etc/agenix` (see `remote-building.nix:21`), so secrets must move to /run or to sops-nix first                                                   | lab only, after secrets move |
| D4  | `system.nixos-init.enable`                             | `activationScripts`                          | bashless init                                                           | makes `activationScripts` a silent no-op — btrbk/restic hooks would stop running without an error                                                                            | lab only                     |
| D5  | `security.pam.settings`                                | per-service booleans                         | freeform PAM config                                                     | upstream marks it subject to breaking changes; a mistake locks you out                                                                                                       | lab only                     |
| D6  | `security.shadow.enable = false` + greetd              | shadow suite provides login/su               | fewer setuid programs                                                   | assertion couples the two; changes VT login semantics                                                                                                                        | lab only                     |
| D7  | `security.apparmor.policies`                           | deprecated `profiles` option                 | policy set is now data                                                  | writing profiles is real work and breakage-prone; `SECURITY.md` explicitly warns against untested profiles                                                                   | lab only                     |

---

# E. Considered and rejected (kept so they are not re-litigated)

| Candidate                | What it is                                                     | Why not here                                                                                                                                                                                                                              |
| ------------------------ | -------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| systemd-sysext / confext | overlay read-only images onto `/usr`/`/etc` of an immutable OS | solves the ostree/Flatcar problem NixOS does not have: generations are already atomic and rollbackable. Layering via sysext means something escaped the rebuild.                                                                          |
| Portable services        | attach/detach a service image at runtime                       | aimed at distributing services to foreign systemd distros; generation switching is strictly stronger here.                                                                                                                                |
| Quadlet                  | podman generator turning `.container` files into units         | NixOS already has `virtualisation.oci-containers` (in use on servers); Quadlet would move unit definitions out of Nix evaluation. A downgrade, not a modernization.                                                                       |
| Landlock                 | unprivileged per-process LSM (network rules since 6.12)        | already an active default LSM (`security/lsm` includes it); the missing piece is per-application policy, and this repo's answer to that is nixpak/bwrap. Watch trigger: nixpak/bwrap gain network-restriction policy.                     |
| Incus                    | LXD fork, container + VM management plane                      | no bridge option in the module (it creates `incusbr0`; attaching to `br0` needs `preseed`); it is a management plane, not a hypervisor replacement, and does not remove libvirt or MicroVM. If adopted, it needs its own disposable host. |
| Gateway API              | k8s ingress successor                                          | cross-repo: it belongs to `~/codes/k8s-gitops` with a matching branch here only if host networking changes. ingress-nginx is EOL, so this is real work — just not this repo's plan.                                                       |
| bcachefs                 | copy-on-write filesystem, out of experimental upstream         | current storage (btrfs + btrbk + restic) works; migration cost is high and unrelated to any pain. Watch only.                                                                                                                             |

---

# F. Decision summary

Fill this in as cards are decided; the plan documents should then be trimmed to **adopt** items
only.

| Card  | Candidate                   | Decision | Date | Note |
| ----- | --------------------------- | -------- | ---- | ---- |
| A1    | Tailscale Serve (partial)   |          |      |      |
| A2    | systemd-resolved            |          |      |      |
| A3    | systemd-networkd            |          |      |      |
| A4    | journald upload/remote      |          |      |      |
| A5    | zram-generator              |          |      |      |
| A6    | nixos-facter                |          |      |      |
| A7    | attic                       |          |      |      |
| A8    | nix-servd + daemon features |          |      |      |
| A9    | sched_ext                   |          |      |      |
| B1    | limine + Secure Boot        |          |      |      |
| B2    | boot.uki                    |          |      |      |
| B3    | systemd-repart images       |          |      |      |
| B4    | initrd repart               |          |      |      |
| B5    | sysupdate                   |          |      |      |
| B6    | measured boot / FIDO2       |          |      |      |
| B7    | systemd-vmspawn             |          |      |      |
| C1–C4 | tooling + cleanups          |          |      |      |
| D1–D7 | lab-only group              |          |      |      |
| E     | rejected set                |          |      |      |

## References

- nixpkgs modules: `system/etc/etc.nix`, `system/activation/nixos-init.nix`,
  `system/boot/loader/limine/limine.nix`,
  `system/boot/systemd/{repart,sysupdate,tpm2,fido2,journald-*}.nix`, `image/{images,repart}.nix`,
  `services/networking/{tailscale-serve,dhcpcd,nat-nftables}.nix`,
  `services/system/{userborn,nix-daemon,zram-generator}.nix`,
  `services/monitoring/prometheus/exporters.nix`.
- NixOS 26.05 release notes; Nix manual, Experimental Features.
- Repo context: `SECURITY.md` (trust zones and control limits), `WORKAROUNDS.md` (WA-001, WA-003,
  WA-008, WA-009, WA-023), `modules/nixos/base/networking/mdns.nix`,
  `hosts/12kingdoms-youko/homelab-services/caddy.nix`,
  `hosts/12kingdoms-youko/homelab-services/README.md`.

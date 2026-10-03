# OS and Homelab Security

This is a personal infrastructure repository, not a supported security product. This document
describes the intended architecture, controls present in source, their limitations, and remaining
work. A configured control is not evidence that it is active on a running machine.

## Reporting problems

For non-sensitive configuration bugs, open an issue with the affected host role and a redacted
reproduction. Do not post credentials, kubeconfigs, private keys, secret contents, or exploit
details that would expose a live service. For sensitive findings, contact the maintainer privately
through the contact information on their GitHub profile first. There is no guaranteed response SLA.

## Threat model and priorities

Protect administrator credentials, desktop application data, cluster/storage state, and the ability
to recover after compromise or an unsuccessful update. Relevant attackers include compromised
applications and dependencies, malicious workloads, and devices or accounts on trusted networks.
Physical theft and boot tampering matter for desktops and physical hosts too.

Prioritize **patching, reducing exposure, least privilege, isolation, and recovery**, in that order
for each affected service. Kernel mitigations and module deny lists are defence in depth, not fixes
for vulnerabilities. A container shares its host kernel; a VM provides a separate kernel but still
exposes a hypervisor and host-side device/share implementations. Neither makes arbitrary code safe.

Use proportionate hardening: preserve normal performance, developer workflows and required cluster
features. Do not globally disable user namespaces, io_uring, SMT or hardware acceleration, switch to
a hardened kernel, or enforce untested AppArmor policies just to maximize restrictions. Prefer
small, reversible controls and narrow exceptions; benchmark before adopting expensive mitigations.

## Architecture and trust boundaries

| Boundary        | Current design                                                                                                       | Limitation                                                                                                                     |
| --------------- | -------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| Administration  | Key-based SSH; root key login retained for Colmena/MicroVM deployment                                                | Deployment credentials are root-equivalent; password login being disabled does not restrict stolen keys                        |
| Host network    | Shared nftables firewall trusts the home LAN, tailnet interface and local Podman bridge; IPv6 link-local is accepted | These are broad trust zones, not service-level least privilege; router exposure and tailnet ACLs require separate verification |
| Monitoring      | Existing firewall rules restrict exporter ports 9100, 9835 and 9633 to the monitoring host over IPv4                 | IPv6 denial is planned in the baseline implementation; current running hosts require separate verification                     |
| VM hosts        | shoryu, shushou and youko run guests behind `br0`; ruby/kana are libvirt guests                                      | A bridge is not network isolation; host compromise affects its guests                                                          |
| k3s             | Three control-plane and three worker MicroVMs; Cilium, API VIP and NFS CSI                                           | Cluster-admin, privileged/host-mounted pods and writable NFS data are powerful trust boundaries                                |
| MicroVM storage | Host store shared read-only through virtiofs; guest `/etc`, `/var` and `/home` persisted in separate images          | Read-only store does not isolate the host-side virtiofs implementation or protect writable guest state                         |
| Desktop apps    | Selected apps use nixpak/bubblewrap; Podman is rootless                                                              | Rules and shared directories vary per app; user namespaces are needed for these sandboxes                                      |
| Secrets         | agenix declarations here, encrypted data in the private nix-secrets repository                                       | Recipients and plaintext file permissions must be reviewed; root on a recipient can read its decrypted secrets                 |
| Supply chain    | Locked flake inputs; explicit binary-cache trust keys; normal user is not a Nix trusted-user                         | A trusted cache or imported Nix module can supply code executed as root; a lock file is not a security audit                   |
| Recovery        | NixOS generations, btrbk/restic and documented backup procedures                                                     | A rollback does not undo compromised data or secrets; backup configuration alone does not prove restore works                  |

Sources: [host layout](hosts/README.md), [k3s deployment](hosts/k8s/README.md),
[firewall](modules/nixos/base/networking/firewall.nix), [SSH](modules/nixos/base/ssh.nix),
[Nix trust](modules/base/nix.nix), [secrets](secrets/README.md), and [backup](BACKUP.md). Cluster
resources are maintained in the separate k8s-gitops repository.

## Kernel and process baseline

The following explicit, overridable baseline is implemented in
[kernel-hardening.nix](modules/nixos/base/kernel-hardening.nix), with Linux eval coverage and
explicit ARM/RISC-V server imports. Source implementation is not runtime verification. Some values
are already kernel/systemd/NixOS defaults; Darwin does not receive Linux sysctls.

| Setting                                           | Value | Effect and compatibility                                                                                                            |
| ------------------------------------------------- | ----- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `kernel.dmesg_restrict`                           | 1     | Kernel log access requires CAP_SYSLOG; journal access has separate permissions                                                      |
| `kernel.kptr_restrict`                            | 2     | Hide pointers printed with `%pK`, even from privileged readers; not a blanket ban on address leaks                                  |
| `kernel.yama.ptrace_scope`                        | 1     | Restrict unrelated-process tracing; child-process debugging and explicit PR_SET_PTRACER exceptions remain possible                  |
| `kernel.perf_event_paranoid`                      | 2     | Restrict unprivileged kernel profiling; user-space profiling remains available; do not assume distro-specific 3/4 semantics         |
| `kernel.unprivileged_bpf_disabled`                | 2     | Disable unprivileged `bpf()` with an administrator-reversible setting; privileged Cilium/agents retain access                       |
| `net.core.bpf_jit_harden`                         | 1     | Harden only unprivileged BPF JIT; do not enable JIT blinding for privileged Cilium/observability workloads                          |
| `vm.unprivileged_userfaultfd`                     | 0     | Restrict unprivileged kernel-mode fault handling, not all userfaultfd usage; `/dev/userfaultfd` permissions are a separate boundary |
| `fs.protected_symlinks`, `fs.protected_hardlinks` | 1     | Mitigate cross-user link attacks; these controls are boolean                                                                        |
| `fs.protected_fifos`, `fs.protected_regular`      | 2     | Restrict unsafe O_CREAT access in world/group-writable sticky directories; shared temporary-file workflows may need adjustment      |

Some values already come from kernel/systemd/NixOS defaults. Explicit declarations make the desired
baseline reviewable; they do not imply the previous system had no protection. Unsupported kernel
features may lack their sysctl paths, especially on custom kernels: runtime verification is
required.

JIT hardening is deliberately limited to unprivileged programs rather than forced on privileged
agents. Together with `unprivileged_bpf_disabled=2`, this preserves Cilium's normal privileged BPF
path while retaining protection if an administrator temporarily permits unprivileged BPF. This is a
configuration trade-off, not a measured claim of zero overhead.

User namespaces remain enabled: disabling them globally conflicts with Nix sandboxing and breaks
rootless containers and application sandboxes. Nonprivileged seccomp filters are not disabled by the
unprivileged `bpf()` restriction. Do not disable Cilium's privileged BPF, tc, container networking,
NFS, or required VM/filesystem modules in pursuit of a larger deny list.

The existing `esp4`, `esp6`, `rxrpc` deny list blocks modprobe/autoload paths. It does not unload
already loaded modules, affect built-in code, or stop a privileged direct module insertion. Verify
an advisory and affected kernel versions before adding CVE claims; search snippets are not evidence.

### Boot integrity and mandatory access control

- ai configures Lanzaboote in [secureboot.nix](hosts/idols-ai/secureboot.nix). Confirm firmware key
  enrollment and actual Secure Boot state with `sbctl status`; do not assume all hosts have it.
- Secure Boot, signed boot images, kernel lockdown and module signature enforcement are distinct
  controls. Test custom kernels and NVIDIA/out-of-tree modules before extending enforcement.
- AppArmor is enabled, but the explicit sudo policy is in complain mode and the default-deny/nix
  scaffolds are disabled. Complain mode logs rather than blocks. Existing FHS-oriented abstractions
  need Nix store path review; this is not broad enforced application confinement.
- Systemd service sandboxing is per-service, not a global policy. Review capabilities, writable
  paths, network access and syscall requirements before tightening an individual service.

See [application hardening](hardening/README.md) for wrapper details.

## Updating, deploying and recovering

1. Check the advisory and affected package/kernel; prioritize active exploitation and reachable
   attack paths. Review changed inputs and cache trust instead of treating updates as inherently
   safe.
2. Run `just test` (must return `true`), build affected systems/runners and review closure
   differences. Evaluate tests cannot prove runtime enforcement or workload compatibility.
3. Record the old system generation/runner and ensure backups and recovery access exist. Use `boot`
   mode for bridge/network-stack changes or broad VM-host updates.
4. Deploy MicroVM closures to the **physical host**, not the guest's read-only store. Install the
   reviewed runner and activate/restart through the documented MicroVM path. Preserve all images.
5. Keep control-plane restarts sequential to retain etcd quorum. Worker concurrency is an explicit
   availability trade-off; simultaneous worker restarts can interrupt all worker workloads.
6. Verify the active/booted generation, guest boot ID, failed units, API VIP `/readyz`, Nodes,
   Cilium, CSI and workloads. Updating a kernel on disk does not patch the running kernel: reboot
   and verify.
7. On failure, restore the recorded generation/runner and recheck health before continuing. Preserve
   rollback roots until stable. If compromise is suspected, isolate first, rotate affected secrets,
   and restore verified data; merely switching generations is not incident recovery.

For the sysctl baseline, query the keys above with `sysctl <key>`, check
`journalctl -b -u systemd-sysctl`, and test rootless Podman, a sandboxed Nix build, desktop
sandboxes, debugging, and cluster networking/storage after activation. Do not globally relax
hardening to hide one application's incompatibility: make a narrow documented exception and test it.

These sysctls are reversible by administrator configuration, unlike `unprivileged_bpf_disabled=1` or
`kexec_load_disabled=1`, which cannot be relaxed without rebooting. This baseline does not enable
the latter or `security.protectKernelImage` (which also disables hibernation).

## API endpoint and TLS

The canonical endpoint is **`https://test-cluster-1.writefor.fun:6443`**. DNS points it to
kube-vip's `192.168.5.193`; the three servers include the DNS name in their serving-certificate
SANs, and the joining servers/agents use that domain. The first server initializes the cluster
without a join address. This is already a domain-based HA endpoint, not a bare-IP client design.

Use the existing authenticated client configuration to verify it:

```sh
k3s kubectl --server=https://test-cluster-1.writefor.fun:6443 --request-timeout=15s get --raw=/readyz
```

Bare-IP access may fail TLS hostname verification because the certificate does not include the VIP
IP SAN. That is not a fault in the canonical endpoint and does not require certificate rotation. If
bare-IP disaster-recovery access becomes an explicit requirement, add that SAN through normal
configuration and certificate lifecycle procedures. Never bypass TLS verification to conceal a
hostname mismatch. Eval tests protect the domain join endpoint and server SAN declarations; live TLS
checks remain necessary after deployment.

## Implementation plan and completed audit findings

### Implementation status

| Component                                                        | Status                                | Runtime verification                                |
| ---------------------------------------------------------------- | ------------------------------------- | --------------------------------------------------- |
| Architecture, agent-first policy, audits and canonical API tests | Included in this documentation change | Only the dated observations below were checked live |
| Explicit sysctl baseline and IPv6 exporter defence               | Implemented in this baseline change   | Not deployed or verified on running hosts           |

### Baseline implementation checks

- An explicit, overridable sysctl baseline preserves user namespaces and privileged BPF performance.
- IPv6 exporter denial precedes broad LAN/tailnet/container rules. The monitoring configuration uses
  IPv4 targets for these ports, so no scrape endpoint migration is needed.
- x86_64/aarch64 eval checks cover baseline values, normal host overrides and generated exporter
  rules. Canonical API endpoint checks for all six cluster nodes already accompany this document.
- A reusable isolated VM check exercises allowed monitoring IPv4 access, denied other IPv4/IPv6
  access to all three exporter ports, retained IPv6 loopback and a reachable ordinary IPv4/IPv6
  service. Run `nix build .#checks.x86_64-linux.security-exporters`, importing only the shared
  firewall, not real-host secrets or workloads, and does not replace deployment-time checks.

### Read-only audit snapshot — 2026-10-03

- **API:** the canonical domain resolves to the VIP; authenticated `/readyz` returned `ok` with
  normal TLS validation. No DNS or certificate changes were needed.
- **ai boot:** `sbctl status` reports Secure Boot enabled and Setup Mode disabled. It also reports
  legacy sbctl configuration; migration is separate work, not permission to change firmware keys.
- **Listeners:** SSH listens on IPv4/IPv6 on sampled VM hosts and a master. SMART exporters bind the
  physical hosts' LAN IPv4 addresses; node_exporter has wildcard listeners. youko's NFS listens on
  IPv4/IPv6, and the sampled master API has a wildcard listener. These are listener observations,
  not proof of reachability from every network or of router/WAN protection.
- **Workload inventory:** 36 of 78 observed pods had host networking, hostPath or explicitly
  privileged containers. They were infrastructure components: Cilium, Istio CNI/ztunnel, NFS CSI,
  kube-vip and OpenTelemetry log agents. Their host access is not automatically a misconfiguration;
  remove it only after validating the component's requirements. Application pods were not flagged by
  this limited check; that does not establish full workload isolation.
- **RBAC:** explicit cluster-admin bindings include `system:masters` and the Flux kustomize/Helm
  controller service accounts. Operators also have broad resource permissions. Flux's bootstrap
  privileges are intentional for cluster reconciliation; Git write access and controller credentials
  therefore remain administration boundaries. This inventory is not a complete effective-access or
  privilege-escalation analysis.
- **NFS:** the golden store is `0755 root:root`, exported read-write to the entire home LAN with
  `sec=sys,no_root_squash`. File mode 0755 does not contain an allowed client with root privileges;
  such a client can act as server root within this export. The network allowlist and client trust
  are therefore material boundaries, not merely filesystem permissions.

Only selected pod security fields, RBAC rules/binding metadata, listeners and export metadata were
queried. Secret contents and raw kubeconfigs were not inspected. No live access policy, workload,
export, credential, DNS record or firmware configuration was changed during the audit.

### Effective-access and credential follow-up — 2026-10-03

- Four authenticated `kubectl auth can-i` probes covered all 40 ServiceAccounts used by current
  pods: reading secrets across namespaces, creating ClusterRoleBindings, escalating ClusterRoles,
  and creating pods in the account's own namespace. Impersonation included the account's normal
  service-account and authenticated groups; no secret contents or real pods/bindings were created.
- Flux Helm/Kustomize controllers and the VictoriaMetrics operator were allowed all four probes.
  Kiali's operator could create ClusterRoleBindings, but the escalation probe was denied; create
  permission alone does not prove unrestricted binding authority. Several controllers, including
  Loki's account, can read secrets across namespaces and need a feature-specific scope review.
- Sampled staging application/default accounts were denied all four probes. This does not prove they
  have no other permissions or cannot read particular secrets in their own namespace; unused
  accounts, named-resource grants, token issuance and indirect escalation remain separate checks.
- Metadata checks on ai, reachable youko and the sampled master found owner-only decrypted files
  (`0400`, `0500`, `0600` or `0000`), not group/world-readable files. ai's user-consumed
  `/etc/agenix` copies have explicit owner-only modes. A symlink's `0777` is not the effective
  target's access mode.
- User-readable credentials are intentional, including `nix-access-tokens` on servers as well as
  desktops. Same-user agents are not isolated from these credentials by Unix file permissions. Mode
  `0000` also does not stop privileged root. Other host/runtime ownership checks and recipient
  membership were not completed; no private recipient repository or secret value was inspected.
- Darwin's activation has a blanket `chown` over `/etc/agenix/*`; on symlink targets this can
  override declared root ownership. Runtime ownership and consumer requirements must be verified
  before replacing it with explicit per-file ownership. Track this source concern as WA-015.

### Sandbox and agent boundaries

The installed agent CLIs run as the normal user, not inside a repository-defined OS sandbox.
AGENTS.md/tool permissions remain important execution policy, but they are not Unix process
isolation. Source review and socket metadata—not reads of private credentials—established:

- The current desktop session's SSH-agent socket is owned by and writable to the current UID.
  Same-user subprocesses can potentially use its signing interface; read-only mounts do not prevent
  socket use. Private-key bytes were not inspected and no signing operation was requested.
- `ssh -G` reports forwarding for explicit `192.168.*` destinations, but not the sampled `shoryu`
  alias or GitHub destination. Do not treat forwarding as enabled for every LAN alias, or remove it
  without checking deployment/build workflows.
- Nixpak apps retain deliberate host networking, GUI/audio/portal/GPU access and selected writable
  document directories. Firefox additionally retains browserpass/GnuPG integration. These are
  filesystem sandboxes, not blanket credential or management-network isolation.
- WeChat retains networking and X11 through its FHS wrapper. Source arguments alone do not prove
  complete runtime isolation. App launch, file chooser, IME, audio/video, GPU and disposable-agent
  probes are still needed before narrowing mounts or sockets.

#### Agent-first diagnostics by host role

- **Homelab:** configured root SSH is an acceptable path for autonomous, task-scoped read-only
  diagnosis. Root access does not authorize deployment, restart, permission changes, destructive
  operations or secret inspection merely because a diagnostic command is available.
- **Core desktops:** prefer normal-user service status, network information, metrics, own-process
  inspection and journal access. Do not add passwordless sudo or remove existing human-admin
  membership/workflows as an incidental security change. ai's normal user can query system-journal
  metadata, including the kernel transport, without sudo; other desktops need their own readback.
  Escalation to root, including local root SSH, needs explicit authorization rather than an
  automatic fallback when a normal-user diagnostic is denied.
- A read-only API or log can still reveal credentials. Use bounded service/time filters and redact
  sensitive output; never dump process environments or raw kubeconfigs. Narrow, reviewed per-service
  log access is preferable when a desktop lacks access. Do not blanket-grant all journals or add a
  generic privileged diagnostic-command dispatcher just for convenience.
- Preserve functioning SSH/browser/GPU integration. Stronger agent OS isolation, if needed, should
  be an explicit workflow design with positive/negative tests, not a collection of surprise denials.

For routine diagnosis, prefer bounded reads such as `systemctl --failed --no-pager`,
`systemctl status SERVICE --no-pager`, `journalctl -u SERVICE -n 200 --no-pager`,
`journalctl --user -u SERVICE -n 200 --no-pager`, `ip -br address`, `ss -lntu` and
`ps -eo pid,comm,stat`. On Homelab these may use the configured root SSH connection; on desktops try
normal-user access first. Do not confuse read-only status with permission to restart a service, or
diagnose a log-access denial by reading credential files or removing protection globally.

### Update/reboot routine and kernel visibility

Recommended cadence: review advisories and pinned inputs weekly, with an out-of-band review for
active exploitation or a reachable high-impact vulnerability. Check affected versions and exposure,
then validate an update and schedule the required rollout/reboot. Do not auto-apply every input bump
or promise that a kernel version string alone proves security coverage.

Verify the booted kernel after each rollout instead of trusting the selected generation. The booted
image and the image selected for the next boot are independent:

- `readlink -f /run/booted-system/kernel` — kernel of the running system closure.
- `readlink -f /nix/var/nix/profiles/system/kernel` — kernel selected for the next boot.

A mismatch means the host still runs the old kernel and a reboot is pending. This catches boot-only
deployments even when `/run/current-system` is unchanged; `uname -r` gives the running release
string. A matching kernel path is not proof of vulnerability age, livepatch state or driver
compatibility, and a generation change that only affects the initrd, modules or userspace leaves the
kernel path unchanged. Guest profiles and a runner staged only on a MicroVM's physical host require
separate verification.

## Remaining prioritized TODOs

| Priority | Work                                                                             | Acceptance / constraints                                                                                                                                        |
| -------- | -------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| P1       | Roll out and verify the implemented baseline/exporter rules                      | Runtime sysctl readback, allowed IPv4 scrape and denied IPv6/non-monitoring scrape tests; preserve Nix/Podman/Cilium/NFS functionality                          |
| P1       | Review router mappings and tailnet ACLs; narrow service exposure where warranted | Audit was limited to sampled host listeners; test intended and denied access without locking out deployment                                                     |
| P1       | Review NFS client scope and root identity requirements                           | Restrict to required VM hosts/CSI nodes where practical; test provisioning, permissions and existing PVCs before changing squash semantics                      |
| P1       | Narrow operator/secret access where justified; finish permission checks          | Selected effective probes and ai/youko modes audited; validate broad secret-reader needs, remaining hosts, recipient scope and Darwin per-file ownership        |
| P1       | Adopt the documented cadence and verify the booted kernel after rollouts         | Routine documented; compare booted and selected kernel paths and recheck API/workloads after reboot; no automated metric is deployed                            |
| P1       | Exercise backup restore and credential rotation                                  | Use an approved isolated restore target and recovery access; never overwrite live data for a drill                                                              |
| P2       | Promote selected AppArmor profiles to enforce; harden exposed systemd services   | Per-app positive/negative tests, store-path coverage, reviewed capabilities and reversible rollout                                                              |
| P2       | Maintain ai boot integrity and assess other host roles                           | Review sbctl configuration migration, recovery boot and signed custom/NVIDIA modules; ai Secure Boot state already verified                                     |
| P2       | Review unused-module deny list against real workloads and verified advisories    | Check loaded/built-in modules and autoload dependencies; do not block required filesystems, WiFi, VM or Cilium/NFS functionality                                |
| P2       | Evaluate stronger controls only against a concrete threat                        | Account for hibernation, crash recovery, applications and performance; no blanket io_uring/SMT/userns ban or hardened-kernel switch                             |
| P2       | Validate narrower sandbox/agent boundaries where needed                          | Source and selected SSH/journal metadata audited; use disposable data/socket probes and preserve core-desktop diagnosis, browserpass and Homelab root workflows |
| P3       | Improve security-event alerts and configuration drift checks                     | Actionable redacted alerts and periodic runtime control readback                                                                                                |

Record temporary exceptions in [WORKAROUNDS.md](WORKAROUNDS.md) with a removal condition. Revisit
this architecture after a new exposed service, network/storage change, host addition or significant
kernel/nixpkgs update. No control here guarantees containment after host root compromise.

## References

- [Linux kernel sysctls](https://docs.kernel.org/admin-guide/sysctl/kernel.html)
- [Filesystem protections](https://docs.kernel.org/admin-guide/sysctl/fs.html)
- [BPF JIT hardening](https://docs.kernel.org/admin-guide/sysctl/net.html#bpf-jit-harden)
- [userfaultfd restrictions](https://docs.kernel.org/admin-guide/sysctl/vm.html#unprivileged-userfaultfd)
- [Yama](https://docs.kernel.org/admin-guide/LSM/Yama.html)
- [Kernel module signing](https://docs.kernel.org/admin-guide/module-signing.html)
- [NixOS security advisories](https://github.com/NixOS/nixpkgs/security/advisories)
- [CISA Known Exploited Vulnerabilities](https://www.cisa.gov/known-exploited-vulnerabilities-catalog)

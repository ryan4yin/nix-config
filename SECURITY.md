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

## Architecture and trust boundaries

| Boundary        | Current design                                                                                                       | Limitation                                                                                                                        |
| --------------- | -------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| Administration  | Key-based SSH; root key login retained for Colmena/MicroVM deployment                                                | Deployment credentials are root-equivalent; password login being disabled does not restrict stolen keys                           |
| Host network    | Shared nftables firewall trusts the home LAN, tailnet interface and local Podman bridge; IPv6 link-local is accepted | These are broad trust zones, not service-level least privilege; router exposure and tailnet ACLs require separate verification    |
| Monitoring      | Shared firewall rules restrict IPv4 access to exporter ports 9100, 9835 and 9633 to the monitoring host              | Equivalent IPv6 source restrictions are missing; broad tailnet/link-local rules may allow IPv6 access when a listener supports it |
| VM hosts        | shoryu, shushou and youko run guests behind `br0`; ruby/kana are libvirt guests                                      | A bridge is not network isolation; host compromise affects its guests                                                             |
| k3s             | Three control-plane and three worker MicroVMs; Cilium, API VIP and NFS CSI                                           | Cluster-admin, privileged/host-mounted pods and writable NFS data are powerful trust boundaries                                   |
| MicroVM storage | Host store shared read-only through virtiofs; guest `/etc`, `/var` and `/home` persisted in separate images          | Read-only store does not isolate the host-side virtiofs implementation or protect writable guest state                            |
| Desktop apps    | Selected apps use nixpak/bubblewrap; Podman is rootless                                                              | Rules and shared directories vary per app; user namespaces are needed for these sandboxes                                         |
| Secrets         | agenix declarations here, encrypted data in the private nix-secrets repository                                       | Recipients and plaintext file permissions must be reviewed; root on a recipient can read its decrypted secrets                    |
| Supply chain    | Locked flake inputs; explicit binary-cache trust keys; normal user is not a Nix trusted-user                         | A trusted cache or imported Nix module can supply code executed as root; a lock file is not a security audit                      |
| Recovery        | NixOS generations, btrbk/restic and documented backup procedures                                                     | A rollback does not undo compromised data or secrets; backup configuration alone does not prove restore works                     |

Sources: [host layout](hosts/README.md), [k3s deployment](hosts/k8s/README.md),
[firewall](modules/nixos/base/networking/firewall.nix), [SSH](modules/nixos/base/ssh.nix),
[Nix trust](modules/base/nix.nix), [secrets](secrets/README.md), and [backup](BACKUP.md). Cluster
resources are maintained in the separate k8s-gitops repository.

## Kernel and process baseline

[kernel-hardening.nix](modules/nixos/base/kernel-hardening.nix) sets the following overridable
defaults for hosts importing it, including the explicit ARM/RISC-V server import lists. Linux eval
tests check the supported x86_64 and aarch64 configurations; Darwin does not receive Linux sysctls.

| Setting                                           | Value | Effect and compatibility                                                                                                            |
| ------------------------------------------------- | ----- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `kernel.dmesg_restrict`                           | 1     | Kernel log access requires CAP_SYSLOG; journal access has separate permissions                                                      |
| `kernel.kptr_restrict`                            | 2     | Hide pointers printed with `%pK`, even from privileged readers; not a blanket ban on address leaks                                  |
| `kernel.yama.ptrace_scope`                        | 1     | Restrict unrelated-process tracing; child-process debugging and explicit PR_SET_PTRACER exceptions remain possible                  |
| `kernel.perf_event_paranoid`                      | 2     | Restrict unprivileged kernel profiling; user-space profiling remains available; do not assume distro-specific 3/4 semantics         |
| `kernel.unprivileged_bpf_disabled`                | 2     | Disable unprivileged `bpf()` with an administrator-reversible setting; privileged Cilium/agents retain access                       |
| `net.core.bpf_jit_harden`                         | 2     | Harden JIT compilation for all users; incurs a performance trade-off, including privileged BPF workloads                            |
| `vm.unprivileged_userfaultfd`                     | 0     | Restrict unprivileged kernel-mode fault handling, not all userfaultfd usage; `/dev/userfaultfd` permissions are a separate boundary |
| `fs.protected_symlinks`, `fs.protected_hardlinks` | 1     | Mitigate cross-user link attacks; these controls are boolean                                                                        |
| `fs.protected_fifos`, `fs.protected_regular`      | 2     | Restrict unsafe O_CREAT access in world/group-writable sticky directories; shared temporary-file workflows may need adjustment      |

Some values already come from kernel/systemd/NixOS defaults. Explicit declarations make the desired
baseline reviewable; they do not imply the previous system had no protection. Unsupported kernel
features may lack their sysctl paths, especially on custom kernels: runtime verification is
required.

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

## Prioritized TODOs

| Priority | Work                                                                                         | Acceptance / constraints                                                                                                                                           |
| -------- | -------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| P1       | Roll out and verify the explicit sysctl baseline                                             | Runtime readback and compatibility checks above; compare BPF workload performance before/after                                                                     |
| P1       | Audit LAN/tailnet/service exposure, including IPv6 and router mappings                       | Add equivalent IPv6 exporter restrictions; document SSH/API/NFS/management reachability and replace broad trust with reviewed rules without locking out deployment |
| P1       | Audit privileged pods, host mounts, cluster-admin access, secrets and NFS export permissions | Review live state and k8s-gitops declarations; demonstrate intended access is allowed and unintended access denied                                                 |
| P1       | Establish an advisory/update/reboot cadence and overdue-kernel visibility                    | Track affected running kernels, not only flake revisions; verify booted versions after rollout                                                                     |
| P1       | Exercise backup restore and credential rotation                                              | Restore selected data into an isolated target and document recovery access; never overwrite live data for a drill                                                  |
| P2       | Promote selected AppArmor profiles to enforce; harden exposed systemd services               | Per-app positive/negative tests, store-path coverage, reviewed capabilities and reversible rollout                                                                 |
| P2       | Verify ai Secure Boot and extend boot integrity by host role                                 | Firmware status, signed image/module checks and recovery boot tested; handle custom/NVIDIA modules explicitly                                                      |
| P2       | Review unused-module deny list against real workloads and verified advisories                | Check loaded/built-in modules and dependency/autoload paths; test required filesystems, WiFi, VM and Cilium/NFS functionality                                      |
| P2       | Evaluate kexec restrictions, io_uring restrictions and hardened kernels per role             | Account for hibernation, crash recovery, applications and performance; do not import the removed NixOS hardened profile                                            |
| P2       | Review sandbox shares and AI-agent access to credentials/management networks                 | Demonstrate denied access to unrelated data without removing needed development workflows                                                                          |
| P3       | Improve security-event alerts and configuration drift checks                                 | Actionable alerts with redacted logs and periodic runtime control readback                                                                                         |

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

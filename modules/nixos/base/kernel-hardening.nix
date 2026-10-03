{ lib, pkgs, ... }:
{
  # Keep this baseline independent of a particular kernel CVE. User namespaces
  # remain available for Nix builds, rootless containers and application sandboxes.
  # See SECURITY.md for compatibility constraints and post-deployment checks.
  boot.kernel.sysctl = {
    "kernel.dmesg_restrict" = lib.mkDefault 1;
    # NixOS already sets mkDefault 1; use a stronger default, still overridable
    # by an ordinary host definition, rather than conflicting at priority 1000.
    "kernel.kptr_restrict" = lib.mkOverride 900 2;
    # Allow debuggers to trace their own children; unrelated processes need
    # CAP_SYS_PTRACE or an explicit PR_SET_PTRACER exception.
    "kernel.yama.ptrace_scope" = lib.mkDefault 1;
    # Upstream documents >=2 as blocking unprivileged kernel profiling. Do not
    # assume distro-specific values 3/4 provide additional upstream protection.
    "kernel.perf_event_paranoid" = lib.mkDefault 2;
    # 2 disables unprivileged BPF but lets an administrator re-enable it without
    # rebooting. Privileged Cilium/observability agents retain their BPF access.
    "kernel.unprivileged_bpf_disabled" = lib.mkDefault 2;
    # Limit JIT hardening to unprivileged programs: do not impose its overhead
    # on privileged Cilium/observability workloads. Userns root is not host root.
    "net.core.bpf_jit_harden" = lib.mkDefault 1;
    "vm.unprivileged_userfaultfd" = lib.mkDefault 0;

    # Symlink/hardlink protection is boolean; FIFO/regular-file protection also
    # supports 2, extending protection to group-writable sticky directories.
    "fs.protected_symlinks" = lib.mkDefault 1;
    "fs.protected_hardlinks" = lib.mkDefault 1;
    "fs.protected_fifos" = lib.mkDefault 2;
    "fs.protected_regular" = lib.mkDefault 2;
  };

  # Blacklist unused kernel modules to shrink the attack surface. esp4/esp6/rxrpc
  # were the vectors for the Dirty Frag LPE (CVE-2026-43284 / CVE-2026-43500);
  # kept as defence in depth even though the upstream fix has long landed, since
  # nothing here uses them.
  boot.blacklistedKernelModules = [
    "esp4"
    "esp6"
    "rxrpc"
  ];

  boot.extraModprobeConfig = ''
    install esp4 ${pkgs.coreutils}/bin/false
    install esp6 ${pkgs.coreutils}/bin/false
    install rxrpc ${pkgs.coreutils}/bin/false
  '';
}

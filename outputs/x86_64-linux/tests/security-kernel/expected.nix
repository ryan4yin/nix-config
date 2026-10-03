{ lib, outputs }:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (_: {
  sysctl = {
    "kernel.dmesg_restrict" = 1;
    "kernel.kptr_restrict" = 2;
    "kernel.yama.ptrace_scope" = 1;
    "kernel.perf_event_paranoid" = 2;
    "kernel.unprivileged_bpf_disabled" = 2;
    "net.core.bpf_jit_harden" = 1;
    "vm.unprivileged_userfaultfd" = 0;
    "fs.protected_symlinks" = 1;
    "fs.protected_hardlinks" = 1;
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;
  };
  allowUserNamespaces = true;
  hostOverride = 1;
})

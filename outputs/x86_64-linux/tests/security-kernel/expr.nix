{ lib, outputs }:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (
  name:
  let
    config = outputs.nixosConfigurations.${name}.config;
    keys = [
      "kernel.dmesg_restrict"
      "kernel.kptr_restrict"
      "kernel.yama.ptrace_scope"
      "kernel.perf_event_paranoid"
      "kernel.unprivileged_bpf_disabled"
      "net.core.bpf_jit_harden"
      "vm.unprivileged_userfaultfd"
      "fs.protected_symlinks"
      "fs.protected_hardlinks"
      "fs.protected_fifos"
      "fs.protected_regular"
    ];
  in
  {
    sysctl = lib.genAttrs keys (key: config.boot.kernel.sysctl.${key} or null);
    # Nix sandbox, rootless Podman and application sandboxes need user namespaces.
    inherit (config.security) allowUserNamespaces;
    # An ordinary host exception must win without mkForce or a merge conflict.
    hostOverride =
      (outputs.nixosConfigurations.${name}.extendModules {
        modules = [ { boot.kernel.sysctl."kernel.kptr_restrict" = 1; } ];
      }).config.boot.kernel.sysctl."kernel.kptr_restrict";
  }
)

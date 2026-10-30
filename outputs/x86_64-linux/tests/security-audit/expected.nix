{
  lib,
  outputs,
}:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (
  name:
  let
    # Homelab servers reachable with the root deployment keys; not desktops.
    audited = builtins.elem name [
      "youko"
      "shoryu"
      "shushou"
      "aquamarine"
    ];
  in
  {
    auditd = audited;
    rootSession = audited;
    sessionsOnly = audited;
    # Only emitted where agenix has secrets: a watch on a missing path
    # aborts loading the remaining rules.
    agenixWatch = name == "youko";
  }
)

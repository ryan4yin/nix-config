{ lib, outputs, ... }:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (
  name:
  let
    config = outputs.nixosConfigurations.${name}.config;
    enabled = config.services.mihomo.enable;
    mihomo = config.systemd.services.mihomo or null;
  in
  {
    # A mihomo host reads its local node lists from a group-restricted directory.
    # Without one of these three the service cannot read them, or the nodes end up
    # inlined in config.yaml: the group, the SAFE_PATHS entry that lets the core
    # open a path outside its `-d` HomeDir, and the group handed to the
    # DynamicUser unit.
    profilesGroupDeclared = (!enabled) || (config.users.groups ? mihomo-profiles);
    profilesSafePath =
      (!enabled)
      || (builtins.elem "SAFE_PATHS=/var/lib/mihomo-profiles" mihomo.serviceConfig.Environment);
    profilesSupplementaryGroup =
      (!enabled) || (builtins.elem "mihomo-profiles" mihomo.serviceConfig.SupplementaryGroups);
  }
)

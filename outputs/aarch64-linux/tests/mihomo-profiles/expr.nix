{ lib, outputs, ... }:
let
  profilesDir = "/var/lib/mihomo-profiles";
  profilesGroup = "mihomo-profiles";

  # a preserved directory is either a bare path or a record with `directory`
  preservedDir = d: if builtins.isAttrs d then (d.directory or "") else d;
in
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (
  name:
  let
    config = outputs.nixosConfigurations.${name}.config;
    enabled = config.services.mihomo.enable;
    mihomo = config.systemd.services.mihomo or null;
    preserved = builtins.any (
      root: builtins.any (d: preservedDir d == profilesDir) (root.directories or [ ])
    ) (builtins.attrValues (config.preservation.preserveAt or { }));
  in
  {
    # A mihomo host reads its local node lists from a group-restricted directory.
    # Without one of these three the service cannot read them, or the nodes end up
    # inlined in config.yaml: the group, the SAFE_PATHS entry that lets the core
    # open a path outside its `-d` HomeDir, and the group handed to the
    # DynamicUser unit.
    profilesGroupDeclared = (!enabled) || (config.users.groups ? ${profilesGroup});
    profilesSafePath =
      (!enabled) || (builtins.elem "SAFE_PATHS=${profilesDir}" mihomo.serviceConfig.Environment);
    profilesSupplementaryGroup =
      (!enabled) || (builtins.elem profilesGroup mihomo.serviceConfig.SupplementaryGroups);

    # On tmpfs-root hosts that directory is a preservation bind mount. Without it
    # a reboot empties it and the local proxy groups come up with no nodes.
    profilesDirPreserved = (!enabled) || (!(config.preservation.enable or false)) || preserved;
  }
)

{
  preservation,
  lib,
  pkgs,
  myvars,
  ...
}:
let
  inherit (myvars) username;
in
{
  imports = [
    preservation.nixosModules.default
  ];

  preservation.enable = true;
  environment.systemPackages = [
    # `sudo gdu -x /`
    pkgs.gdu
  ];

  # NOTE: `preservation` only mounts the directory/file list below to /persistent
  # If the directory/file already exists in the root filesystem you should
  # move those files/directories to /persistent first!
  preservation.preserveAt."/persistent" = {
    directories = [
      "/etc/NetworkManager/system-connections"
      # Mount in initrd: NixOS copies mode-carrying /etc entries (such as
      # authorized_keys.d) during stage-2 activation, which runs before systemd
      # starts. A mount created by preservation.target comes later and would
      # hide those copies behind the previous `switch`, so key changes only
      # applied on `switch`, never on `boot` + reboot.
      {
        directory = "/etc/ssh";
        inInitrd = true;
      }
      "/etc/nix/inputs"
      "/etc/secureboot" # lanzaboote - secure boot
      # my secrets
      "/etc/agenix/"

      "/var/log"
      "/var/lib"
      "/var/cache"

      # k3s related
      "/etc/iscsi"
      "/etc/rancher"
    ];
    files = [
      # auto-generated machine ID
      {
        file = "/etc/machine-id";
        inInitrd = true;
      }
    ];

    # the following directories will be passed to /persistent/home/$USER
    users.${username} = {
      directories = [
        "codes"
        "nix-config"
        "tmp"
      ];
    };
  };

  # Create some directories with custom permissions.
  #
  # In this configuration the path `/home/butz/.local` is not an immediate parent
  # of any persisted file so it would be created with the systemd-tmpfiles default
  # ownership `root:root` and mode `0755`. This would mean that the user `butz`
  # could not create other files or directories inside `/home/butz/.local`.
  #
  # Therefore systemd-tmpfiles is used to prepare such directories with
  # appropriate permissions.
  #
  # Note that immediate parent directories of persisted files can also be
  # configured with ownership and permissions from the `parent` settings if
  # `configureParent = true` is set for the file.
  systemd.tmpfiles.settings.preservation =
    let
      permission = {
        user = username;
        group = lib.mkForce username;
        mode = lib.mkForce "0750";
      };
    in
    {
      "/home/${username}/.config".d = permission;
      "/home/${username}/.local".d = permission;
      "/home/${username}/.local/share".d = permission;
      "/home/${username}/.local/state".d = permission;
      "/home/${username}/.terraform.d".d = permission;
    };

  # Mask the commit service: /etc/machine-id is persisted by preservation
  # (see the `files` entry above), so there is no transient ID to commit.
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

  # Inert while the unit is masked above; kept as the alternative approach.
  systemd.services.systemd-machine-id-commit = {
    unitConfig.ConditionPathIsMountPoint = [
      ""
      "/persistent/etc/machine-id"
    ];
    serviceConfig.ExecStart = [
      ""
      "systemd-machine-id-setup --commit --root /persistent"
    ];
  };
}

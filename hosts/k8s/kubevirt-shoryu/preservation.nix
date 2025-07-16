{
  preservation,
  pkgs,
  myvars,
  ...
}: let
  inherit (myvars) username;
in {
  imports = [
    preservation.nixosModules.default
  ];

  preservation.enable = true;
  boot.initrd.systemd.enable = true;

  environment.systemPackages = [
    # `sudo ncdu -x /`
    pkgs.ncdu
  ];

  # NOTE: `preservation` only mounts the directory/file list below to /persistent
  # If the directory/file already exists in the root filesystem you should
  # move those files/directories to /persistent first!
  preservation.preserveAt."/persistent" = {
    directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/ssh"
      "/etc/nix/inputs"
      "/etc/secureboot" # lanzaboote - secure boot
      # my secrets
      "/etc/agenix/"

      "/var/log"
      "/var/lib"

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
  systemd.tmpfiles.settings.preservation = let
    permission = {
      user = username;
      group = "users";
      mode = "0755";
    };
  in {
    "/home/${username}/.config".d = permission;
    "/home/${username}/.local".d = permission;
    "/home/${username}/.local/share".d = permission;
    "/home/${username}/.local/state".d = permission;
    "/home/${username}/.terraform.d".d = permission;
  };

  # systemd-machine-id-commit.service would fail but it is not relevant
  # in this specific setup for a persistent machine-id so we disable it
  #
  # see the firstboot example below for an alternative approach
  systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];

  # let the service commit the transient ID to the persistent volume
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

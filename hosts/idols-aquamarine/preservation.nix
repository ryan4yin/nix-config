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
    # Whole-filesystem disk usage (`-x` stays on one filesystem):
    #   sudo gdu -n -x /            # non-interactive, plain text
    pkgs.gdu
  ];

  # NOTE: preservation only mounts the directory/file list below to /persistent
  # If the directory/file already exists in the root filesystem you should
  # move those files/directories to /persistent first!
  preservation.preserveAt."/persistent" = {
    directories = [
      "/etc/ssh"
      "/etc/nix/inputs"
      "/etc/secureboot" # lanzaboote - secure boot (see ./secureboot.nix)

      "/var/log"
      "/var/lib"
      "/var/cache"
      # Re-creatable scratch, but it must not consume the root tmpfs (RAM), so
      # it is bind-mounted onto the persistent volume and wiped at boot below.
      # The mode must stay 1777 to match that `D!` rule.
      {
        directory = "/var/tmp";
        mode = "1777";
        mountOptions = [
          "nosuid"
          "nodev"
        ];
      }
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
        # Rootless Podman's image and layer store. On the root tmpfs the 4 GiB root
        # fills up during the first build, so it lives on the persistent volume
        # like it does on `ai`.
        ".local/share/containers"
        "codes"
        # Third-party source checkouts, the same layout `ai` uses: Strata, the
        # inference engine whose image this host builds, lives at ~/src/Strata.
        "src"
        "nix-config"
        "tmp"
        # Model weights live here. The root filesystem is tmpfs, so anything
        # not listed is gone on the next boot; weights are re-downloadable, but
        # re-downloading tens of GB is not a boot step.
        "models"

        # Caches. A cold flake cache makes `nix run <flake-ref>` re-download its
        # input at boot, which needs DNS, and on a tmpfs root cache writes are RAM.
        ".cache"

        ".config/systemd/user"
        ".config/containers/systemd"
      ];
    };
  };

  # The parents of the persisted paths below are not themselves persisted, so
  # tmpfiles would create them root:root 0755 and the user could not write under
  # them. Same fix as hosts/idols-ai/preservation.nix.
  systemd.tmpfiles.settings.preservation = {
    "/home/${username}/.cache".d = {
      user = username;
      group = lib.mkForce username;
      mode = lib.mkForce "0750";
    };
    "/home/${username}/.config".d = {
      user = username;
      group = lib.mkForce username;
      mode = lib.mkForce "0750";
    };
    "/home/${username}/.config/systemd".d = {
      user = username;
      group = lib.mkForce username;
      mode = lib.mkForce "0750";
    };
    "/home/${username}/.config/containers".d = {
      user = username;
      group = lib.mkForce username;
      mode = lib.mkForce "0750";
    };
    "/home/${username}/.local".d = {
      user = username;
      group = lib.mkForce username;
      mode = lib.mkForce "0750";
    };
    "/home/${username}/.local/share".d = {
      user = username;
      group = lib.mkForce username;
      mode = lib.mkForce "0750";
    };
  };

  systemd.tmpfiles.rules = [
    # /var/tmp only accumulates between reboots (mirrors `boot.tmp.cleanOnBoot`
    # for /tmp). Crash dumps can hold secrets copied out of process memory.
    "D! /var/tmp 1777 root root"
    "D! /var/lib/systemd/coredump 0755 root root"
  ];

  # Mask the commit service: /etc/machine-id is persisted by preservation
  # (see the `files` entry above), so there is no transient ID to commit.
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
}

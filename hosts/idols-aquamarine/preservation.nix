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
    # Mount in initrd: NixOS copies mode-carrying /etc entries (such as
    # authorized_keys.d) during stage-2 activation, which runs before systemd
    # starts. A mount created by preservation.target comes later and would hide
    # those copies behind the previous `switch`, so key changes only applied on
    # `switch`, never on `boot` + reboot. Preparing the mount in initrd puts
    # /persistent/etc/ssh at /sysroot/etc/ssh before activation runs.
    directories = [
      {
        directory = "/etc/ssh";
        inInitrd = true;
      }
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

        # ======================================
        # Home Manager TUI role (home/linux/tui.nix); the same paths `ai` keeps
        # ======================================
        ".local/state/home-manager"
        ".local/state/nix/profiles"
        ".local/share/nix"
        ".config/nushell" # history

        # ai agents
        ".agents" # skills for all agents
        ".config/agents"
        ".codex"
        ".dsh" # DeepSeek Harness
        ".pi"
        ".config/opencode"
        ".local/share/opencode"
        ".local/state/opencode"
        # Raft Computer state: server enrollment keys, agent state, traces,
        # app storage and the installer's runtime cache. The installer itself
        # is ~/.local/bin/raft-computer, covered by the .local/bin entry below.
        {
          directory = ".raft";
          mode = "0700";
        }
        # ctx7 docs lookup login
        {
          directory = ".config/context7";
          mode = "0700";
        }

        # editors
        ".local/share/nvim"
        ".local/state/nvim"
        ".local/share/jupyter"

        # tuios session state, project-tape trust store and layout templates
        {
          directory = ".local/state/tuios";
          mode = "0700";
        }
        {
          directory = ".local/share/tuios";
          mode = "0700";
        }
        ".config/tuios"

        # cloud native
        {
          directory = ".aws";
          mode = "0700";
        }
        {
          directory = ".aliyun";
          mode = "0700";
        }
        {
          directory = ".config/gcloud";
          mode = "0700";
        }
        # GitHub CLI config, including the plaintext OAuth token in
        # hosts.yml (0600) by explicit choice for this non-primary account.
        # Only aqua is authorized; kana/ruby remain logged out.
        {
          directory = ".config/gh";
          mode = "0700";
        }
        {
          directory = ".kube";
          mode = "0700";
        }
        ".terraform.d/plugin-cache"

        # language package managers
        ".npm"
        "go"
        ".cargo"
        ".local/bin"
        ".local/share/uv"

        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }
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
    "/home/${username}/.local/state".d = {
      user = username;
      group = lib.mkForce username;
      mode = lib.mkForce "0750";
    };
    "/home/${username}/.local/state/nix".d = {
      user = username;
      group = lib.mkForce username;
      mode = lib.mkForce "0750";
    };
    "/home/${username}/.terraform.d".d = {
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

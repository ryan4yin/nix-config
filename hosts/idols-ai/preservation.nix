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
  # pverservation required initrd using systemd.
  boot.initrd.systemd.enable = true;

  environment.systemPackages = [
    # Whole-filesystem disk usage (`-x` stays on one filesystem):
    #   sudo gdu -n -x /            # non-interactive, plain text
    #   sudo gdu -o /tmp/gdu.json / # JSON export
    pkgs.gdu
  ];

  # There are two ways to clear the root filesystem on every boot:
  ##  1. use tmpfs for /
  ##  2. (btrfs/zfs only)take a blank snapshot of the root filesystem and revert to it on every boot via:
  ##     boot.initrd.postDeviceCommands = ''
  ##       mkdir -p /run/mymount
  ##       mount -o subvol=/ /dev/disk/by-uuid/UUID /run/mymount
  ##       btrfs subvolume delete /run/mymount
  ##       btrfs subvolume snapshot / /run/mymount
  ##     '';
  #
  #  See also https://grahamc.com/blog/erase-your-darlings/

  # NOTE: preservation only mounts the directory/file list below to /persistent
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
      # system caches (e.g. restic, plocate; slow to rebuild)
      "/var/cache"
      # General scratch space. It is re-creatable and can grow large, so keep it
      # off the root tmpfs and on the persistent volume. Contents only
      # accumulate between reboots: the tmpfiles rule below wipes it at boot.
      # World-writable scratch, so harden the bind mount like /tmp; the mode
      # must stay 1777 to match that `D!` rule.
      {
        directory = "/var/tmp";
        mode = "1777";
        mountOptions = [
          "nosuid"
          "nodev"
        ];
      }
      # btrbk state/home (SSH keys, cache). The owner must match the btrbk
      # module's `d /var/lib/btrbk 0750 btrbk btrbk` rule, which preservation
      # would otherwise override with the default root:root.
      {
        directory = "/var/lib/btrbk";
        user = "btrbk";
        group = "btrbk";
        mode = "0750";
      }
      # CUPS state (the print spool lives in /var/spool/cups, not here)
      "/var/lib/cups"

      # system-core
      "/var/lib/nixos"
      "/var/lib/systemd"
      # upower device battery history (e.g. Magic Trackpad)
      "/var/lib/upower"
      {
        directory = "/var/lib/private";
        mode = "0700";
      }

      # containers
      # "/var/lib/docker"
      "/var/lib/cni"
      "/var/lib/containers"

      # virtualisation
      "/var/lib/libvirt"
      "/var/lib/qemu"
      # "/var/lib/waydroid"

      # network
      "/var/lib/bluetooth"
      "/var/lib/NetworkManager"
      "/var/lib/iwd"
      "/var/lib/tailscale"

      # logrotate state. Persist the directory: a single-file bind mount cannot
      # be replaced by logrotate's atomic rename() (EBUSY).
      "/var/lib/logrotate"
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
      commonMountOptions = [
        "x-gvfs-hide"
      ];
      directories = [
        # ======================================
        # XDG Directories
        # ======================================

        "Desktop"
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"

        # Keep .cache off tmpfs to avoid high RAM usage; many apps use it and it is storage-heavy.
        ".cache"

        # NOTE: do NOT persist ~/.local/share/Trash here. The trash crate (nushell
        # `rm --trash`) picks the home trash only when the file's mount topdir equals
        # the trash dir's topdir; a bind-mounted Trash dir would make files straight
        # under $HOME fail with EACCES (it would try /.Trash-$uid). The home trash on
        # tmpfs is lost on reboot, which is acceptable: scattered per-mount
        # .Trash-$uid dirs on persistent volumes are covered by the trash-empty
        # retention timer (modules/nixos/base/trash.nix).

        # ======================================
        # Codes / Work / Playground
        # ======================================
        "codes" # for personal code
        "work" # work code tree
        "src" # third-party source checkouts
        "nix-config"
        "tmp"

        # ======================================
        # Nix / Home Manager Profiles
        # ======================================

        ".local/state/home-manager"
        ".local/state/nix/profiles"
        ".local/state/noctalia" # shell settings, notification/clipboard history
        ".local/share/nix"

        # ======================================
        # IDE / Editors
        # ======================================

        # vscode
        ".vscode"
        ".config/Code"

        # zed
        ".config/zed"
        ".local/share/zed"

        # ai agents
        ".agents" # skills for all agents
        ".config/agents"
        ".codex"
        ".dsh" # DeepSeek Harness
        ".pi"
        ".config/opencode"
        ".local/share/opencode"
        ".local/state/opencode"

        ".context7" # up-to-date docs and code examples for for LLMs & agents

        # nvim
        ".local/share/nvim"
        ".local/state/nvim"

        # Joplin
        ".config/joplin" # tui client
        ".config/Joplin" # joplin-desktop

        ".local/share/jupyter"
        ".ipython"

        # ======================================
        # Cloud Native
        # ======================================
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
        {
          directory = ".config/gh";
          mode = "0700";
        }
        {
          directory = ".kube";
          mode = "0700";
        }
        ".terraform.d/plugin-cache" # terraform's plugin cache

        # ======================================
        # language package managers
        # ======================================
        ".npm" # typsescript/javascript
        "go"
        ".cargo" # rust
        ".m2" # java maven
        ".gradle" # java gradle
        ".conda" # python generated by `conda-shell`
        ".local/bin"
        # python uv
        ".local/share/uv"

        # ======================================
        # Security
        # ======================================

        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }
        {
          directory = ".pki";
          mode = "0700";
        }
        {
          directory = ".local/share/password-store";
          mode = "0700";
        }
        {
          # gnmome keyrings
          directory = ".local/share/keyrings";
          mode = "0700";
        }

        # ======================================
        # Games / Media
        # ======================================

        "Games"
        # .desktop entries created by games/installers (including the umu
        # launchers the nix-config-umu-game skill generates). Home Manager
        # rewrites its mimeapps.list symlink into the bind mount at activation,
        # so that survives too.
        ".local/share/applications"
        ".steam"
        ".config/MangoHud"
        ".config/blender"

        ".local/share/umu"

        ".local/share/Steam"
        ".local/state/Heroic"
        ".config/heroic"
        ".config/lutris"
        ".local/share/lutris"

        ".local/share/GOG.com"
        ".local/share/StardewValley"
        ".local/share/feral-interactive"

        # ======================================
        # Meeting / Remote Desktop / Recording
        # ======================================
        ".zoom"
        ".config/obs-studio"
        ".config/Moonlight Game Streaming Project"
        ".config/sunshine"
        ".config/freerdp"

        ".config/remmina"
        ".local/share/remmina"

        # ======================================
        # browsers
        # ======================================
        ".mozilla"
        ".config/google-chrome"
        ".config/chromium"
        ".config/BraveSoftware/Brave-Origin"
        ".config/microsoft-edge"

        # ======================================
        # CLI data
        # ======================================
        ".local/share/atuin"
        ".local/share/zoxide"
        ".local/share/direnv"
        ".local/share/k9s"

        # ======================================
        # Containers
        # ======================================
        ".local/share/containers"
        # nixpak app's data
        {
          directory = ".var";
          mode = "0700";
        }

        # ======================================
        # Misc
        # ======================================

        # Mihomo (native core): sources spec, generator and config all live here
        # (contains subscription secrets, hence 0700).
        {
          directory = ".config/mihomo";
          mode = "0700";
        }

        # Orca Slicer - 3D Printer Slicer
        ".local/share/orca-slicer"
        ".config/OrcaSlicer"

        # Bambu Studio - 3D Printer Slicer
        ".local/share/bambu-studio"
        ".config/BambuStudio"

        # Audio
        ".config/pulse"
        ".local/state/wireplumber"

        # go-musicfox - TUI NetEase Cloud Music client
        # ~/.config/go-musicfox/config.toml is force-managed by Home Manager
        # (see home/linux/gui/base/go-musicfox/default.nix) and reset on each
        # rebuild; this keeps the runtime themes/ directory and the app's
        # between-rebuild config edits.
        ".config/go-musicfox"
        ".local/share/go-musicfox" # login cookie + library db
        ".local/state/go-musicfox" # logs

        # Digital Painting
        ".local/share/krita"

        # Japanese IME
        ".config/mozc" # used by fcitx5-mozc

        # Vinput voice input (fcitx5-vinput): core config.json + downloaded
        # sherpa-onnx models (~/.local/share/vinput/models/). Without these the
        # daemon starts with "Local ASR provider model is not configured" after
        # every reboot. Setup commands: home/linux/gui/base/vinput/README.md
        ".config/vinput"
        ".local/share/vinput"

        ".config/nushell"
      ];
      files = [
        {
          file = ".config/zoomus.conf";
          how = "symlink";
        }
        {
          file = ".config/zoom.conf";
          how = "symlink";
        }
      ];
    };
  };

  # Keep logrotate's state inside the directory preserved above instead of the
  # default /var/lib/logrotate.status (a mount point `rename()` cannot replace).
  services.logrotate.extraArgs = [
    "--state"
    "/var/lib/logrotate/status"
  ];

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
      "/home/${username}/.local/state/nix".d = permission;
      "/home/${username}/.terraform.d".d = permission;
    };

  # /var/tmp is re-creatable scratch, but it must not consume RAM, so it is
  # bind-mounted onto the persistent volume above. Wipe it at boot (mirrors
  # nixpkgs `boot.tmp.cleanOnBoot` for /tmp) so contents only accumulate
  # between reboots.
  #
  # Crash dumps live in the persisted /var/lib/systemd and can contain secrets
  # copied out of process memory, so don't keep them across reboots either.
  systemd.tmpfiles.rules = [
    "D! /var/tmp 1777 root root"
    "D! /var/lib/systemd/coredump 0755 root root"
  ];

  # systemd-machine-id-commit.service would fail but it is not relevant
  # in this specific setup for a persistent machine-id so we disable it
  #
  # see the firstboot example below for an alternative approach
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

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

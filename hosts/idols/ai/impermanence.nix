{
  impermanence,
  pkgs,
  ...
}: {
  imports = [
    impermanence.nixosModules.impermanence
  ];

  environment.systemPackages = [
    # `sudo ncdu -x /`
    pkgs.ncdu
  ];

  # There are two ways to clear the root filesystem on every boot:
  ##  1. use tmpfs for /
  ##  2. (btrfs/zfs only)take a blank snapshot of the root filesystem and revert to it on every boot via:
  ##  3. boot.initrd.postDeviceCommands = ''
  ##       mkdir -p /run/mymount
  ##       mount -o subvol=/ /dev/disk/by-uuid/UUID /run/mymount
  ##       btrfs subvolume delete /run/mymount
  ##       btrfs subvolume snapshot / /run/mymount
  ##     '';
  #
  #  See also https://grahamc.com/blog/erase-your-darlings/
  environment.persistence."/persistent" = {
    # sets the mount option x-gvfs-hide on all the bind mounts
    # to hide them from the file manager
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/ssh"
      "/etc/nix/inputs"
      "/etc/secureboot" # lanzaboote - secure boot
      # my secrets
      "/etc/agenix/"

      "/var/log"
      "/var/lib"

      # created by modules/nixos/fhs-fonts.nix
      # for flatpak apps
      # "/usr/share/fonts"
      # "/usr/share/icons"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.ryan = {
      directories = [
        "codes"
        "nix-config"
        "tmp"

        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"

        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }
        {
          directory = ".aws";
          mode = "0700";
        }
        {
          directory = ".docker";
          mode = "0700";
        }
        {
          directory = ".kube";
          mode = "0700";
        }

        # misc
        ".config/pulse"
        ".pki"

        # remote desktop
        ".config/remmina"
        ".config/freerdp"

        # browsers
        ".mozilla"
        ".config/google-chrome"

        # neovim / remmina / flatpak / ...
        ".local/share"
        ".local/state"

        # language package managers
        ".npm"
        "go"

        # neovim plugins(wakatime & copilot)
        ".wakatime"
        ".config/github-copilot"
      ];
      files = [
        ".wakatime.cfg"
        ".config/nushell/history.txt"
      ];
    };
  };
}

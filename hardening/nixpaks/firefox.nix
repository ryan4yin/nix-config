{
  lib,
  pkgs,
  mkNixPak,
  nixpak-pkgs,
  ...
}:
mkNixPak {
  config = {
    config,
    sloth,
    ...
  }: {
    app = {
      package = pkgs.firefox-wayland;
      binPath = "bin/firefox";
    };
    flatpak.appId = "org.mozilla.firefox";

    imports = [
      "${nixpak-pkgs}/pkgs/modules/gui-base.nix"
      "${nixpak-pkgs}/pkgs/modules/network.nix"
    ];

    # https://github.com/schizofox/schizofox/blob/main/modules/hm/default.nix
    dbus.policies = {
      "org.mozilla.firefox.*" = "own"; # firefox
      # "org.mozilla.firefox_beta.*" = "own"; # firefox beta (?)
      # "io.gitlab.librewolf.*" = "own";      # librewolf
    };

    bubblewrap = {
      bind.rw = [
        (sloth.concat' sloth.homeDir "/.mozilla")
        (sloth.concat' sloth.homeDir "/Downloads")

        # ================ for externsions ===============================
        # required by https://github.com/browserpass/browserpass-extension
        (sloth.concat' sloth.homeDir "/.local/share/password-store") # pass
      ];
      bind.ro = [
        # To actually make Firefox run
        "/sys/bus/pci"
        ["${config.app.package}/lib/firefox" "/app/etc/firefox"]

        "/etc/fonts"
        "/etc/machine-id"
        "/etc/localtime"
        "/run/opengl-driver"

        # Unsure
        (sloth.concat' sloth.xdgConfigHome "/dconf")
      ];

      network = true;
      sockets = {
        x11 = false;
        wayland = true;
        pipewire = true;
      };
      bind.dev = [
        "/dev/dri"
        "/dev/shm"
        "/run/dbus"

        # required when using nvidia as primary gpu
        "/dev/nvidia-uvm"
        "/dev/nvidia-modeset"
      ];
      tmpfs = [
        "/tmp"
      ];

      env = {
        XDG_DATA_DIRS = lib.mkForce (lib.makeSearchPath "share" (with pkgs; [
          adw-gtk3
          tela-icon-theme
          shared-mime-info
        ]));
        XCURSOR_PATH = lib.mkForce (lib.concatStringsSep ":" (with pkgs; [
          "${tela-icon-theme}/share/icons"
          "${tela-icon-theme}/share/pixmaps"
          "${simp1e-cursors}/share/icons"
          "${simp1e-cursors}/share/pixmaps"
        ]));
      };
    };
  };
}

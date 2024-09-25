# Refer:
# - Flatpak manifest's docs:
#   - https://docs.flatpak.org/en/latest/manifests.html
#   - https://docs.flatpak.org/en/latest/sandbox-permissions.html
# - Firefox's flatpak manifest: https://hg.mozilla.org/mozilla-central/file/tip/taskcluster/docker/firefox-flatpak/runme.sh#l151
{
  lib,
  pkgs,
  mkNixPak,
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
      ./modules/gui-base.nix
      ./modules/network.nix
    ];

    # list all dbus services:
    #   ls -al /run/current-system/sw/share/dbus-1/services/
    #   ls -al /etc/profiles/per-user/ryan/share/dbus-1/services/
    dbus.policies = {
      "org.mozilla.firefox.*" = "own"; # firefox
      "org.mozilla.firefox_beta.*" = "own"; # firefox beta
      "org.mpris.MediaPlayer2.firefox.*" = "own";
      "org.freedesktop.NetworkManager" = "talk";
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

        # Unsure
        (sloth.concat' sloth.xdgConfigHome "/dconf")
      ];

      sockets = {
        x11 = false;
        wayland = true;
        pipewire = true;
      };
      bind.dev = [
        "/dev/shm" # Shared Memory
      ];
      tmpfs = [
        "/tmp"
      ];
    };
  };
}

{
  lib,
  pkgs,
  mkNixPak,
  nixpak-pkgs,
  ...
}:
mkNixPak
{
  config = {sloth, ...}: {
    flatpak = {
      appId = "com.tencent.mm";
    };
    bubblewrap = {
      bind.rw = [
        [
          (sloth.mkdir (sloth.concat [sloth.xdgDocumentsDir "/WeChat_Data"]))
          (sloth.concat' sloth.homeDir "/xwechat_files")
        ]
      ];
      bind.ro = [
        # Absolutely required. Missing any of them will cause you not able to launch wechat
        "/etc/fonts"
        "/etc/machine-id"
        "/etc/localtime"
        "/etc/passwd"

        # Certificates. Required for SSL connections. Kind of optional
        "/etc/ssl/certs/ca-bundle.crt"
        "/etc/ssl/certs/ca-certificates.crt"
        "/etc/pki/tls/certs/ca-bundle.crt"

        # Will read, but optional
        #"/etc/hosts"
        #"/etc/host.conf"
        #"/etc/resolv.conf"
        #"/etc/nsswitch.conf"
        #"/etc/group"
        #"/etc/shadow"
        #"/etc/profiles"
        #"/etc/sudoers.d"
        #"/etc/sudoers"
        #"/etc/zoneinfo"
        #"/etc/asound.conf"

        #"/sys/dev/char"
        #"/sys/devices"
      ];
      network = true;
      sockets = {
        x11 = true;
        wayland = true;
        pipewire = true;
      };
      bind.dev = [
        "/dev/dri"
        "/dev/shm"
        "/dev/video0"
        "/dev/video1"
      ];
      tmpfs = [
        "/tmp"
      ];
      env = {
        IBUS_USE_PORTAL = "1";
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

    imports = [
      "${nixpak-pkgs}/pkgs/modules/gui-base.nix"
      "${nixpak-pkgs}/pkgs/modules/network.nix"
    ];
    app = {
      package = pkgs.wechat-uos.override {
        uosLicense = pkgs.fetchurl {
          url = "https://aur.archlinux.org/cgit/aur.git/plain/license.tar.gz?h=wechat-uos-bwrap";
          hash = "sha256-U3YAecGltY8vo9Xv/h7TUjlZCyiIQdgSIp705VstvWk=";
        };
      };
      binPath = "bin/wechat-uos";
    };
  };
}

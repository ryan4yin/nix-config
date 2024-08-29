{
  pkgs,
  mkNixPak,
  nixpak-pkgs,
  safeBind,
  ...
}:
mkNixPak {
  config = {sloth, ...}: {
    app = {
      package = pkgs.netease-cloud-music-gtk;
      binPath = "netease-cloud-music-gtk4";
    };
    flatpak.appId = "com.gitee.gmg137.NeteaseCloudMusicGtk4";

    imports = [
      "${nixpak-pkgs}/pkgs/modules/gui-base.nix"
      "${nixpak-pkgs}/pkgs/modules/network.nix"
    ];
    dbus.policies = {
      # "org.freedesktop.portal.Flatpak" = "talk";
      "org.freedesktop.portal.FileChooser" = "talk";
    };
    bubblewrap = {
      bind.rw = [
        (safeBind sloth "/share" "/.local/share")
        (safeBind sloth "/lyrics" "/.lyrics")
        [
          (sloth.mkdir (sloth.concat' sloth.appDataDir "/config"))
          sloth.xdgConfigHome
        ]
        (sloth.concat' sloth.homeDir "/Music")
      ];
      sockets = {
        wayland = true;
        pipewire = true;
      };
      bind.dev = [
        "/dev/dri"
      ];
      tmpfs = ["/tmp"];
    };
  };
}

{pkgs, ...}: let
  firejailWrapper = import ./firejailWrapper.nix pkgs;
in {
  programs.firejail.enable = true;

  # Add firejailed Apps into nixsuper, and reference them in home-manager or other nixos modules
  nixpkgs.overlays = [
    (_: super: {
      firejailed = {
        steam = firejailWrapper {
          name = "steam-firejailed";
          executable = "${super.steam}/bin/steam";
          profile = "${super.firejail}/etc/firejail/steam.profile";
        };
        steam-run = firejailWrapper {
          name = "steam-run-firejailed";
          executable = "${super.steam}/bin/steam-run";
          profile = "${super.firejail}/etc/firejail/steam.profile";
        };

        # firefox = firejailWrapper {
        #   name = "firefox-firejailed";
        #   executable = "${super.lib.getBin super.firefox-wayland}/bin/firefox";
        #   profile = "${super.firejail}/etc/firejail/firefox.profile";
        # };
        # chromium = firejailWrapper {
        #   name = "chromium-firejailed";
        #   executable = "${super.lib.getBin super.ungoogled-chromium}/bin/chromium";
        #   profile = "${super.firejail}/etc/firejail/chromium.profile";
        # };

        mpv = firejailWrapper {
          executable = "${super.lib.getBin super.mpv}/bin/mpv";
          profile = "${super.firejail}/etc/firejail/mpv.profile";
        };
        imv = firejailWrapper {
          executable = "${super.lib.getBin super.imv}/bin/imv";
          profile = "${super.firejail}/etc/firejail/imv.profile";
        };
        zathura = firejailWrapper {
          executable = "${super.lib.getBin super.zathura}/bin/zathura";
          profile = "${super.firejail}/etc/firejail/zathura.profile";
        };
        discord = firejailWrapper {
          executable = "${super.lib.getBin super.discord}/bin/discord";
          profile = "${super.firejail}/etc/firejail/discord.profile";
        };
        slack = firejailWrapper {
          executable = "${super.lib.getBin super.slack}/bin/slack";
          profile = "${super.firejail}/etc/firejail/slack.profile";
        };
        telegram-desktop = firejailWrapper {
          executable = "${super.lib.getBin super.tdesktop}/bin/telegram-desktop";
          profile = "${super.firejail}/etc/firejail/telegram-desktop.profile";
        };
        brave = firejailWrapper {
          executable = "${super.lib.getBin super.brave}/bin/brave";
          profile = "${super.firejail}/etc/firejail/brave.profile";
        };
        qutebrowser = firejailWrapper {
          executable = "${super.lib.getBin super.qutebrowser}/bin/qutebrowser";
          profile = "${super.firejail}/etc/firejail/qutebrowser.profile";
        };
        thunar = firejailWrapper {
          executable = "${super.lib.getBin super.xfce.thunar}/bin/thunar";
          profile = "${super.firejail}/etc/firejail/thunar.profile";
        };
        vscodium = firejailWrapper {
          executable = "${super.lib.getBin super.vscodium}/bin/vscodium";
          profile = "${super.firejail}/etc/firejail/vscodium.profile";
        };
      };
    })
  ];
}

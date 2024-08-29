{pkgs, ...}: let
  firejailWrapper = import ./firejailWrapper.nix pkgs;
in {
  programs.firejail.enable = true;

  # Add firejailed Apps into nixpkgs, and reference them in home-manager or other nixos modules
  nixsuper.overlays = [
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

        firefox = firejailWrapper {
          name = "firefox-firejailed";
          executable = "${super.lib.getBin super.firefox}/bin/firefox";
          profile = "${super.firejail}/etc/firejail/firefox.profile";
        };
        chromium = firejailWrapper {
          name = "chromium-firejailed";
          executable = "${pkgs.lib.getBin pkgs.ungoogled-chromium}/bin/chromium";
          profile = "${pkgs.firejail}/etc/firejail/chromium.profile";
        };
      };
    })
  ];
}

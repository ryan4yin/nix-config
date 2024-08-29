{pkgs, ...}: let
  firejailWrapper = import ./firejailWrapper.nix pkgs;
in {
  nixsuper.overlays = [
    (_: super: {
      firejailed = {
        firefox = firejailWrapper {
          name = "firefox-firejailed";
          executable = "${super.lib.getBin super.firefox}/bin/firefox";
          profile = "${super.firejail}/etc/firejail/firefox.profile";
        };
        steam = {
          executable = "${super.steam}/bin/steam";
          profile = "${super.firejail}/etc/firejail/steam.profile";
        };
        steam-run = {
          executable = "${super.steam}/bin/steam-run";
          profile = "${super.firejail}/etc/firejail/steam.profile";
        };
      };
    })
  ];
}

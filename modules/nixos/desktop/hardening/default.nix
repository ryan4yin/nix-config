{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/hardened.nix")
  ];

  # disable coredump that could be exploited later
  # and also slow down the system when something crash
  systemd.coredump.enable = false;

  # required to run chromium
  security.chromiumSuidSandbox.enable = true;

  # enable firejail
  programs.firejail.enable = true;

  # create system-wide executables firefox and chromium
  # that will wrap the real binaries so everything
  # work out of the box.
  programs.firejail.wrappedBinaries = {
    firefox = {
      executable = "${pkgs.lib.getBin pkgs.firefox}/bin/firefox";
      profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
    };
    chromium = {
      executable = "${pkgs.lib.getBin pkgs.chromium}/bin/chromium";
      profile = "${pkgs.firejail}/etc/firejail/chromium.profile";
    };
  };
}

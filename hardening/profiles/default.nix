{modulesPath, ...}: {
  imports = [
    (modulesPath + "/profiles/hardened.nix")
  ];

  # disable coredump that could be exploited later
  # and also slow down the system when something crash
  systemd.coredump.enable = false;

  # required to run chromium
  security.chromiumSuidSandbox.enable = true;

  # enable firejail
  programs.firejail.enable = true;
}

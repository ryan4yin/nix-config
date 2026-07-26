{
  lib,
  myvars,
  ...
}:
#############################################################
#
#  Shoukei - NixOS running on Macbook Pro 2022 M2 16G
#
#############################################################
let
  hostName = "shoukei"; # Define your hostname.
in
{
  imports = [
    ./hardware-configuration.nix
    ../idols-ai/preservation.nix
  ];

  # disable sunshine for securrity
  services.sunshine.enable = lib.mkForce false;
  services.tuned.ppdSettings.main.default = lib.mkForce "power-saver";

  # This laptop joins untrusted networks and the firewall is disabled
  # (modules/nixos/base/ssh.nix), so a 0.0.0.0:9100 node-exporter would be exposed
  # to whatever network it is on. It is no longer scraped anyway - disable it.
  services.prometheus.exporters.node.enable = lib.mkForce false;

  networking = {
    inherit hostName;
    inherit (myvars.networking) nameservers;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}

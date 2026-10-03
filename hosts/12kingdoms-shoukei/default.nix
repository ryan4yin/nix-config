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

  # Laptop joins untrusted networks and is no longer scraped; don't expose :9100.
  services.prometheus.exporters.node.enable = lib.mkForce false;

  # resolvconf restarts nscd on every /etc/resolv.conf rewrite (see
  # /etc/resolvconf.conf). Boot network churn exceeds the default start limit
  # (5/10s) and latches nscd into `failed`, which also fails nss-lookup.target /
  # nss-user-lookup.target; `try-restart` cannot revive it. nscd cannot be
  # disabled (NixOS loads NSS modules through it, see nsswitch.nix), so don't
  # rate-limit these external restarts and back off on the crash path instead.
  systemd.services.nscd = {
    startLimitIntervalSec = 0;
    serviceConfig = {
      RestartSec = "1s";
      RestartSteps = 5;
      RestartMaxDelaySec = "60s";
    };
  };

  networking = {
    inherit hostName;
    inherit (myvars.networking) nameservers;
  };

  fileSystems."/btr_pool" = {
    device = "/dev/disk/by-uuid/c2e8b249-240e-4eef-bf4e-81e7dbbf4887";
    fsType = "btrfs";
    options = [ "subvolid=5" ];
  };

  modules.btrbk.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}

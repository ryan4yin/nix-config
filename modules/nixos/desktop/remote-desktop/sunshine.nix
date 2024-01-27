{
  config,
  lib,
  pkgs,
  ...
}:
# ===============================================================================
#
# Sunshine: A self-hosted game stream server for Moonlight(Client).
# It's designed for game streaming, but it can be used for remote desktop as well.
#
# TODO: currently broken, fixed but not released yet: https://github.com/LizardByte/Sunshine/pull/1977
#
# How to use(Web Console: <https://localhost:47990/>):
#  https://docs.lizardbyte.dev/projects/sunshine/en/latest/about/usage.html
#
# Check Service Status
#   systemctl --user status sunshine
# Check logs
#   journalctl --user -u sunshine --since "2 minutes ago"
#
# References:
#   https://github.com/LongerHV/nixos-configuration/blob/c7a06a2125673c472946cda68b918f68c635c41f/modules/nixos/sunshine.nix
#   https://github.com/RandomNinjaAtk/nixos/blob/fc7d6e8734e6de175e0a18a43460c48003108540/services.sunshine.nix
#
# ===============================================================================
{
  security.wrappers.sunshine = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+p";
    source = "${pkgs.sunshine}/bin/sunshine";
  };

  # Requires to simulate input
  boot.kernelModules = ["uinput"];
  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"
  '';

  # systemd.user.services.sunshine = {
  #   description = "A self-hosted game stream server for Moonlight(Client)";
  #   after = ["graphical-session-pre.target"];
  #   wants = ["graphical-session-pre.target"];
  #   wantedBy = ["graphical-session.target"];
  #   startLimitIntervalSec = 500;
  #   startLimitBurst = 5;
  #
  #   serviceConfig = {
  #     ExecStart = "${config.security.wrapperDir}/sunshine";
  #     Restart = "on-failure";
  #     RestartSec = "5s";
  #   };
  # };

  networking.firewall = {
    allowedTCPPortRanges = [
      {
        from = 47984;
        to = 48010;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 47998;
        to = 48010;
      }
    ];
  };
}

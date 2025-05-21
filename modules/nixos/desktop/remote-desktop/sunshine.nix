# ===============================================================================
#
# Sunshine: A self-hosted game stream server for Moonlight(Client).
# It's designed for game streaming, but it can be used for remote desktop as well.
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
#   https://github.com/NixOS/nixpkgs/blob/nixos-25.05/nixos/modules/services/networking/sunshine.nix
#
# ===============================================================================
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # only needed for Wayland -- omit this when using with Xorg
    openFirewall = true;
  };
}

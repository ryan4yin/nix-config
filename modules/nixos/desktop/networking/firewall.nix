# Desktops hold personal data and laptops join untrusted networks, so enable the
# firewall here (repo-wide default is off, see modules/nixos/base/ssh.nix).
# SSH/Tailscale/LocalSend/Sunshine keep working via their own `openFirewall` options.
{
  networking.firewall = {
    enable = true;
    # Trust everything from the tailnet.
    trustedInterfaces = [ "tailscale0" ];
  };
}

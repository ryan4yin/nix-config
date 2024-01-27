{
  config,
  pkgs,
  ...
}:
# =============================================================
#
# Tailscale - your own private network(VPN) that uses WireGuard
#
# It's open souce and free for personal use,
# and it's really easy to setup and use.
# Tailscale has great client coverage for Linux, windows, Mac, android, and iOS.
# Tailscale is more mature and stable compared to other alternatives such as netbird/netmaker.
# Maybe I'll give netbird/netmaker a try when they are more mature, but for now, I'm sticking with Tailscale.
#
# How to use:
#  1. Create a Tailscale account at https://login.tailscale.com
#  2. Login via `tailscale login`
#  3. join into your Tailscale network via `tailscale up`
#  4. If you prefer automatic connection to Tailscale, then generate a authkey, and uncomment the systemd service below.
#
# Status Data:
#   `journalctl -u tailscaled` shows tailscaled's logs
#   logs indicate that tailscale store its data in /var/lib/tailscale
#   which is already persistent across reboots(via impermanence.nix)
#
# References:
#   https://tailscale.com/blog/nixos-minecraft
#
# =============================================================
{
  # make the tailscale command usable to users
  environment.systemPackages = [pkgs.tailscale];

  # enable the tailscale service
  services.tailscale.enable = true;

  # create a oneshot job to authenticate to Tailscale
  # systemd.services.tailscale-autoconnect = {
  #   description = "Automatic connection to Tailscale";
  #
  #   # make sure tailscale is running before trying to connect to tailscale
  #   after = ["network-pre.target" "tailscale.service"];
  #   wants = ["network-pre.target" "tailscale.service"];
  #   wantedBy = ["multi-user.target"];
  #
  #   # set this service as a oneshot job
  #   serviceConfig.Type = "oneshot";
  #
  #   # have the job run this shell script
  #   script = with pkgs; ''
  #     # wait for tailscaled to settle
  #     sleep 2
  #
  #     # check if we are already authenticated to tailscale
  #     status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
  #     if [ $status = "Running" ]; then # if so, then do nothing
  #       exit 0
  #     fi
  #
  #     # otherwise authenticate with tailscale
  #     ${tailscale}/bin/tailscale up -authkey file:${config.age.secrets.tailscale-authkey.path}
  #   '';
  # };

  networking.firewall = {
    # always allow traffic from your Tailscale network
    trustedInterfaces = ["tailscale0"];

    # allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [config.services.tailscale.port];

    # allow you to SSH in over the public internet
    allowedTCPPorts = [22];
  };
}

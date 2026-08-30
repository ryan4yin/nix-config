{ pkgs-master, ... }:
# NOTE: There is a known pitfall with mihomo's fake-IP for IPv6
# (fake-ip-range6: fdfe:dcba:9876::/64): TCP connections to IPv6 fake-IPs are
# not proxied correctly and simply hang until connect() times out.
# Clients without a fast IPv4 fallback stall for ~2 minutes per attempt:
# every git remote operation (fetch/pull/push alike, they all go through ssh)
# hangs on "Connecting to ssh.github.com [fdfe:dcba:9876::x] port 443"
# before falling back to IPv4.
# Browsers recover silently thanks to Happy Eyeballs (RFC 8305: when a name
# resolves to both IPv4 and IPv6, the client tries one stack first, then races
# the other after a ~50ms delay and keeps whichever connects first).
# Fix: disable IPv6 in Clash Verge's DNS/TUN settings (confirmed working);
# or work around per-client, e.g. `AddressFamily inet` in ssh_config
# (see home/base/tui/ssh.nix).
{
  programs.clash-verge = {
    enable = true;
    package = pkgs-master.clash-verge-rev;
    autoStart = false;
    serviceMode = true;
    tunMode = true;
  };
}

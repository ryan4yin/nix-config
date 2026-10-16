{
  config,
  myvars,
  ...
}:
let
  # The wired link to the router, i.e. the one that leaves through the Mesh WiFi
  # backhaul to the homelab. Taken from `hostsAddr` so a NIC rename cannot leave
  # these tunings pointing at a table that no longer exists.
  iface = myvars.networking.hostsAddr.${config.networking.hostName}.iface;
in
{
  # WA-035: the mesh backhaul drops unicast to a peer whose MAC it has aged out
  # while still flooding broadcast, so a connection to an idle peer waits for the
  # kernel to give up on unicast ARP and fall back to broadcast. Walk that
  # neighbour state machine in ~1s instead of ~10s, which fits inside ssh's 5s
  # retry window (see `home/base/tui/ssh.nix` for the other half).
  #
  # Cost: while a peer is genuinely down, probes go out 5x faster for the same
  # bounded count -- one unicast probe, then the unchanged broadcast attempts. The
  # failed-neighbour re-probe pace (`interval_probe_time_ms`) is deliberately left
  # alone, so a peer that stays down is not probed more often than before.
  #
  # `default` and the link's own table are both set: a device copies `default`
  # when it is registered, so a later write to `default` does not reach a table
  # that already exists.
  boot.kernel.sysctl = {
    "net.ipv4.neigh.default.delay_first_probe_time" = 1; # revalidate after 1s, not 5s
    "net.ipv4.neigh.default.retrans_time_ms" = 200; # probe every 200ms, not 1s
    "net.ipv4.neigh.default.ucast_solicit" = 1; # one unicast probe, then broadcast
    "net.ipv4.neigh.${iface}.delay_first_probe_time" = 1;
    "net.ipv4.neigh.${iface}.retrans_time_ms" = 200;
    "net.ipv4.neigh.${iface}.ucast_solicit" = 1;
  };
}

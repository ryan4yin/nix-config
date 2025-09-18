{
  # for security reasons, only open the following ports to the network by default.
  networking.firewall.allowedTCPPorts = [
    # localsend
    53317

    # tcp ports for testing & sharing
    63080
    63081
    63082
    63083
    63084
    63085
    63086
    63087
    63088
    63089
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
}

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

  # Network discovery, mDNS
  # With this enabled, you can access your machine at <hostname>.local
  # it's more convenient than using the IP address.
  # https://avahi.org/
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      domain = true;
      userServices = true;
    };
  };

  # Use an NTP server located in the mainland of China to synchronize the system time
  networking.timeServers = [
    "ntp.aliyun.com" # Aliyun NTP Server
    "ntp.tencent.com" # Tencent NTP Server
  ];

  # dynamically update /etc/hosts for testing
  # Note that changes made in this way will be discarded when switching configurations.
  environment.etc.hosts.mode = "0644";
}

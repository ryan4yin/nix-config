{
  # Network discovery on a local network, mDNS
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

  # avahi and systemd-resolved both run an mDNS responder, which makes mDNS
  # unreliable ("Detected another IPv4/IPv6 mDNS stack running on this host").
  # Keep avahi (needed for DNS-SD, e.g. CUPS printer discovery) and turn off
  # resolved's own mDNS.
  services.resolved.settings.Resolve.MulticastDNS = false;
}

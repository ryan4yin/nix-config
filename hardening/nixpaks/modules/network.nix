# https://github.com/nixpak/pkgs/blob/master/pkgs/modules/network.nix
{
  etc.sslCertificates.enable = true;
  bubblewrap.network = true;
  # pasta's default isolate mode gives the app its own loopback, so host
  # services on 127.0.0.1 are out of reach. Proxying still works because
  # mihomo runs in TUN mode, which sees pasta's outbound traffic.
  pasta.enable = true;
}

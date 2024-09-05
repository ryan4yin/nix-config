# https://github.com/nixpak/pkgs/blob/master/pkgs/modules/network.nix
{
  etc.sslCertificates.enable = true;
  bubblewrap = {
    bind.ro = ["/etc/resolv.conf"];
    network = true;
  };
}

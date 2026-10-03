{ pkgs, networking }:
let
  inherit (pkgs) lib;
  myvars = { inherit networking; };
  node = ipv4: ipv6: {
    networking.interfaces.eth1 = {
      ipv4.addresses = lib.mkForce [
        {
          address = ipv4;
          prefixLength = 24;
        }
      ];
      ipv6.addresses = [
        {
          address = ipv6;
          prefixLength = 64;
        }
      ];
    };
    environment.systemPackages = [ pkgs.netcat-openbsd ];
    virtualisation.memorySize = 384;
  };
in
pkgs.testers.runNixOSTest {
  name = "security-exporter-dual-stack";
  nodes = {
    server = {
      imports = [
        ../modules/nixos/base/networking/firewall.nix
        (node "192.168.5.200" "fd42:1::200")
      ];
      _module.args = { inherit myvars; };
      # Model trusted IPv6 traffic after the exporter guards, like the tailnet
      # or k3s pod-network trust. Other IPv6 services must remain usable.
      networking.firewall.extraInputRules = lib.mkAfter ''
        ip6 saddr fd42:1::/64 accept
      '';
      systemd.services = lib.genAttrs [ "9100" "9633" "9835" "8080" ] (port: {
        wantedBy = [ "multi-user.target" ];
        serviceConfig.ExecStart = "${pkgs.socat}/bin/socat TCP6-LISTEN:${port},ipv6only=0,reuseaddr,fork EXEC:${pkgs.coreutils}/bin/cat";
      });
    };
    monitor = node networking.hostsAddr.youko.ipv4 "fd42:1::183";
    client = node "192.168.5.199" "fd42:1::199";
  };
  testScript = ''
    start_all()
    server.wait_for_unit("multi-user.target")
    monitor.wait_for_unit("multi-user.target")
    client.wait_for_unit("multi-user.target")
    for port in (9100, 9633, 9835, 8080):
        server.wait_for_unit(f"{port}.service")
        server.wait_for_open_port(port)
    for port in (9100, 9633, 9835):
        monitor.succeed(f"nc -z -w 3 192.168.5.200 {port}")
        client.fail(f"nc -z -w 3 192.168.5.200 {port}")
        monitor.fail(f"nc -6 -z -w 3 fd42:1::200 {port}")
        client.fail(f"nc -6 -z -w 3 fd42:1::200 {port}")
        server.succeed(f"nc -6 -z -w 3 ::1 {port}")
    client.succeed("nc -z -w 3 192.168.5.200 8080")
    client.succeed("nc -6 -z -w 3 fd42:1::200 8080")
  '';
}

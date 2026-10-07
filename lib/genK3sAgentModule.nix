{
  pkgs,
  masterHost,
  tokenFile,
  nodeLabels ? [ ],
  k3sExtraArgs ? [ ],
  ...
}:
let
  package = pkgs.k3s;
in
{
  environment.systemPackages = [ package ];

  networking.enableIPv6 = true;
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # Deny pods the credential-bearing host ports before the pod accept below.
  networking.firewall.extraInputRules = pkgs.lib.mkAfter ''
    ip  saddr 10.0.0.0/8 tcp dport { 22, 2049, 2283, 5432, 5900, 5901, 5902, 5903, 8000, 8081, 8082, 9090, 9093, 9100, 9633, 9835 } drop
    ip6 saddr fd00::/104 tcp dport { 22, 2049, 2283, 5432, 5900, 5901, 5902, 5903, 8000, 8081, 8082, 9090, 9093, 9100, 9633, 9835 } drop
    ip  saddr 10.0.0.0/8 accept
    ip6 saddr fd00::/104 accept
  '';

  services.k3s = {
    enable = true;
    inherit package tokenFile;

    role = "agent";
    serverAddr = "https://${masterHost}:6443";
    # https://docs.k3s.io/cli/agent
    extraFlags =
      let
        flagList = [
          "--data-dir /var/lib/rancher/k3s"
        ]
        ++ (map (label: "--node-label=${label}") nodeLabels)
        ++ k3sExtraArgs;
      in
      pkgs.lib.concatStringsSep " " flagList;
  };

  # Share k3s's CNI dirs with plugins using the conventional paths (cilium, istio-cni).
  systemd.tmpfiles.rules = [
    "L+ /opt/cni/bin - - - - /var/lib/rancher/k3s/data/cni/"
    "d /var/lib/rancher/k3s/agent/etc/cni/net.d 0751 root root - -"
    "L+ /etc/cni/net.d - - - - /var/lib/rancher/k3s/agent/etc/cni/net.d"
  ];
}

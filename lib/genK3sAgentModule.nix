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

  # Kernel modules required by cilium
  boot.kernelModules = [
    "ip6_tables"
    "ip6table_mangle"
    "ip6table_raw"
    "ip6table_filter"
  ];
  networking.enableIPv6 = true;
  networking.nat = {
    enable = true;
    enableIPv6 = true;
  };

  # Pods may reach the host services they need, but they are not part of the
  # host's trusted LAN. Deny the credential-bearing host ports before the broad
  # pod-network accept below, so a compromised pod cannot reach NFS, the
  # database, the backup server, the VNC consoles, or an exporter. `mkAfter`
  # keeps this after the shared base rules (incl. the node_exporter drop).
  # Ports 80/443 stay reachable so in-cluster calls through the ingress are not
  # broken; the ingress is the authentication boundary there.
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

  # Link k3s's CNI directories to the conventional locations, so CNI plugins
  # that write to /etc/cni/net.d or /opt/cni/bin (cilium, istio-cni) share them
  # with k3s. Without this, cilium writes /etc/cni/net.d while istio-cni reads
  # k3s's own dir, and the chained plugin never finds a network config.
  # Mirrors the server module.
  systemd.tmpfiles.rules = [
    "L+ /opt/cni/bin - - - - /var/lib/rancher/k3s/data/cni/"
    "d /var/lib/rancher/k3s/agent/etc/cni/net.d 0751 root root - -"
    "L+ /etc/cni/net.d - - - - /var/lib/rancher/k3s/agent/etc/cni/net.d"
  ];
}

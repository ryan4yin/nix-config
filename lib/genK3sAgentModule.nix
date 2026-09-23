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

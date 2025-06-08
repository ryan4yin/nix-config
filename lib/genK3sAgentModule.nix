{
  pkgs,
  masterHost,
  tokenFile,
  nodeLabels ? [],
  ...
}: let
  package = pkgs.k3s;
in {
  environment.systemPackages = [package];

  # Kernel modules required by cilium
  boot.kernelModules = ["ip6_tables" "ip6table_mangle" "ip6table_raw" "ip6table_filter"];
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
    extraFlags = let
      flagList =
        [
          "--data-dir /var/lib/rancher/k3s"
        ]
        ++ (map (label: "--node-label=${label}") nodeLabels);
    in
      pkgs.lib.concatStringsSep " " flagList;
  };
}

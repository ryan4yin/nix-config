{
  pkgs,
  masterHost,
  tokenFile,
  nodeLabels ? [],
  ...
}: let
  package = pkgs.k3s_1_29;
in {
  environment.systemPackages = [package];
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

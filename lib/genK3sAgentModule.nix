{
  pkgs,
  serverIp,
  tokenFile,
  ...
}: let
  package = pkgs.k3s_1_29;
in {
  environment.systemPackages = [package];
  services.k3s = {
    enable = true;
    inherit package tokenFile;

    role = "agent";
    serverAddr = "https://${serverIp}:6443";
    # https://docs.k3s.io/cli/agent
    extraFlags =
      " --node-label=node-type=worker"
      + " --data-dir /var/lib/rancher/k3s";
  };
}

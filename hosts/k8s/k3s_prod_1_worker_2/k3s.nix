{
  config,
  pkgs,
  vars_networking,
  ...
}: let
  serverName = "k3s-prod-1-master-1";
  serverIp = vars_networking.hostAddress.${serverName}.address;
  package = pkgs.k3s_1_29;
in {
  environment.systemPackages = [package];
  services.k3s = {
    inherit package;
    enable = true;
    role = "agent";
    serverAddr = "https://${serverIp}:6443";
    tokenFile = config.age.secrets."k3s-prod-1-token".path;
    # https://docs.k3s.io/cli/agent
    extraFlags = "--data-dir /var/lib/rancher/k3s";
  };
}

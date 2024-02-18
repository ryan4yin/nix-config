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
    role = "server";
    serverAddr = "https://${serverIp}:6443";
    tokenFile = config.age.secrets."k3s-prod-1-token".path;
    # https://docs.k3s.io/cli/server
    extraFlags =
      " --write-kubeconfig /etc/k3s/kubeconfig.yml"
      + " --write-kubeconfig-mode 644"
      + " --service-node-port-range 80-32767"
      + " --data-dir /var/lib/rancher/k3s"
      + " --disable-helm-controller"
      + " --etcd-expose-metrics true"
      + ''--etcd-snapshot-schedule-cron "0 */12 * * *"'';
  };
}

{
  config,
  pkgs,
  username,
  ...
}: let
  package = pkgs.k3s_1_29;
in {
  environment.systemPackages = with pkgs; [
    package
    k9s
    kubectl
    istioctl
    kubernetes-helm

    skopeo
    dive # explore docker layers
  ];
  services.k3s = {
    inherit package;
    enable = true;

    # Initialize HA cluster using an embedded etcd datastore.
    # If you are configuring an HA cluster with an embedded etcd,
    # the 1st server must have `clusterInit = true`
    # and other servers must connect to it using serverAddr.
    clusterInit = true;
    role = "server";
    tokenFile = "/run/media/nixos_k3s/kubevirt-k3s-token";
    # https://docs.k3s.io/cli/server
    extraFlags =
      " --write-kubeconfig /etc/k3s/kubeconfig.yml"
      + " --write-kubeconfig-mode 644"
      + " --service-node-port-range 80-32767"
      + " --kube-apiserver-arg='--allow-privileged=true'" # required by kubevirt
      + " --data-dir /var/lib/rancher/k3s"
      + " --disable-helm-controller"
      + " --etcd-expose-metrics true"
      + ''--etcd-snapshot-schedule-cron "0 */12 * * *"'';
  };
}

{
  pkgs,
  kubeconfigFile,
  tokenFile,
  # Initialize HA cluster using an embedded etcd datastore.
  # If you are configuring an HA cluster with an embedded etcd,
  # the 1st server must have `clusterInit = true`
  # and other servers must connect to it using `serverAddr`.
  serverIp ? null,
  clusterInit ? (serverIp == null),
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
    enable = true;
    inherit package tokenFile clusterInit;
    serverAddr =
      if clusterInit
      then ""
      else "https://${serverIp}:6443";

    role = "server";
    # https://docs.k3s.io/cli/server
    extraFlags =
      " --write-kubeconfig ${kubeconfigFile}"
      + " --write-kubeconfig-mode 644"
      + " --service-node-port-range 80-32767"
      + " --kube-apiserver-arg='--allow-privileged=true'" # required by kubevirt
      + " --node-taint=CriticalAddonsOnly=true:NoExecute" # prevent workloads from running on the master
      + " --data-dir /var/lib/rancher/k3s"
      + " --etcd-expose-metrics true"
      + " --etcd-snapshot-schedule-cron '0 */12 * * *'"
      # disable some features we don't need
      + " --disable-helm-controller" # we use fluxcd instead
      + " --disable=traefik" # deploy our own ingress controller instead
      + " --disable=servicelb" # we use kube-vip instead
      + " --flannel-backend=none" # we use cilium instead
      + " --disable-network-policy";
  };
}

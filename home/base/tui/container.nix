{
  pkgs,
  pkgs-unstable,
  nur-ryan4yin,
  ...
}: {
  home.packages = with pkgs; [
    podman-compose
    dive # explore docker layers
    lazydocker # Docker terminal UI.
    skopeo # copy/sync images between registries and local storage
    go-containerregistry # provides `crane` & `gcrane`, it's similar to skopeo

    kubectl
    kubectx # kubectx & kubens
    kubectl-view-secret # kubectl view-secret
    kubectl-tree # kubectl tree
    kubectl-node-shell # exec into node
    kubepug # kubernetes pre upgrade checker

    kubebuilder
    istioctl
    clusterctl # for kubernetes cluster-api
    kubevirt # virtctl
    kubernetes-helm
    fluxcd
    argocd

    ko # build go project to container image
  ];

  programs.k9s.enable = true;
  catppuccin.k9s.transparent = true;

  programs.kubecolor = {
    enable = true;
    enableAlias = true;
  };
}

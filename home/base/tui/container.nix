{
  pkgs,
  pkgs-2505,
  nur-ryan4yin,
  ...
}:
{
  home.packages = with pkgs; [
    podman-compose
    dive # explore docker layers
    go-containerregistry # provides `crane` & `gcrane`

    kubectl
    kustomize
    kubeconform # FAST Kubernetes manifests validator, with support for Custom Resources
    kubectx # kubectx & kubens
    kubie # same as kubectl-ctx, but per-shell (won’t touch kubeconfig).
    kubectl-view-secret # kubectl view-secret
    kubectl-tree # kubectl tree
    kubectl-node-shell # exec into node
    kubepug # kubernetes pre upgrade checker
    kubectl-cnpg # cloudnative-pg's cli tool

    istioctl
    pkgs-2505.kubernetes-helm
    fluxcd
    # argocd
  ];

  programs.k9s.enable = true;
  catppuccin.k9s.transparent = true;

  programs.kubecolor = {
    enable = true;
    enableAlias = true;
  };
}

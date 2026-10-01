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

    # `skopeo`: inspect/move images between registries and local formats
    # (oci / dir / docker-archive) without a daemon; also supports sync + signing.
    #   skopeo list-tags docker://nginx                  # list tags
    #   skopeo inspect docker://nginx:latest             # inspect, no pull
    #   skopeo copy docker://src:1 docker://dst:1        # registry -> registry
    #   skopeo copy --all docker://src:1 docker://dst:1  # every architecture
    #   skopeo copy docker://nginx:latest oci:/tmp/n:latest
    #   skopeo sync --src docker --dest dir nginx /tmp/n
    skopeo

    kubectl
    kustomize
    kubeconform # FAST Kubernetes manifests validator, with support for Custom Resources
    kubectx # kubectx & kubens
    kubie # same as kubectl-ctx, but per-shell (won’t touch kubeconfig).
    kubectl-view-secret # kubectl view-secret
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

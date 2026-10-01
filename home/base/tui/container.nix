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

    # `go-containerregistry` provides `crane` & `gcrane`: inspect and move OCI
    # images without a container daemon or a local pull.
    #   crane ls nginx                                 # list tags
    #   crane manifest nginx:latest                    # view manifest
    #   crane digest nginx:latest                      # image digest
    #   crane export nginx - | tar -tvf -              # browse image filesystem
    #   crane cp src.example/app:1 dst.example/app:1   # copy image between registries
    #   gcrane cp ghcr.io/org/img:1 registry.example/org/img:1
    go-containerregistry

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

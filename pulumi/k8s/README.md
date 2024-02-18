# Kubernetes


## Why Pulumi for Kubernetes?

1. Deploying Helm charts declaratively.
   - Helm CLI supports only imperative commands, you need to add a repository, update the repository, 
     and install the chart with a single command,
     it's really hard to manage the lifecycle of the Helm chart in this way.
    - Pulumi can deploy Helm charts declaratively, you can manage the lifecycle of the Helm chart easily.
1. Deal with secrets in a secure way.
1. Deploying Kubernetes resources in a unified way, instead of running a bunch of commands like `kubectl apply`, `helm install`, `kustomize`, etc.

## Why not ArgoCD or FluxCD?

ArgoCD & FluxCD support only Kubernetes, and it's too heavy for my use case.

Pulumi supports not only Kubernetes but also other cloud providers like Proxmox, Libvirt, AWS, Azure, GCP, etc.
It's a unified way to manage the lifecycle of all my infrastructure resources.


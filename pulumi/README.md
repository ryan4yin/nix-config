# Pulumi - Infrastructure as Code

> WIP, not working yet.

My infrastructure is managed by Pulumi & NixOS.

[Pulumi AI](https://www.pulumi.com/ai/) is a Chatbot based on GPT v4, it can help you to write Pulumi code.

## Why Pulumi for Kubernetes?

1. Deploying Helm charts & yaml files in the right order, in a declarative way.
   - Helm CLI supports only imperative commands, you need to run a bunch of commands like `helm repo add`, `helm repo update`, `helm install`, `helm upgrade`, etc.
     it's really hard to manage the lifecycle of the Helm chart in this way.
1. Deal with secrets in a secure way.
1. Deploying Kubernetes resources in a unified way, instead of running a bunch of commands like `kubectl apply`, `helm install`, `kustomize`, etc.

## Why not ArgoCD or FluxCD?

ArgoCD & FluxCD support only Kubernetes, and it's too heavy for my use case.

Pulumi supports not only Kubernetes but also other cloud providers like Proxmox, Libvirt, AWS, Azure, GCP, etc.
It's a unified way to manage the lifecycle of all my infrastructure resources.


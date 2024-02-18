# Kubernetes Clusters

> WIP, not finished yet.

I'm running two Kubernetes clusters, one for production and one for testing.

I prefer to use [k3s] as the Kubernetes distribution, because it's lightweight, easy to install, and full featured(see [what-have-k3s-removed-from-upstream-kubernetes] for details).

## Hosts

![](/_img/2024-02-18_k8s-nodes-overview.webp)

1. For production:
   1. `k3s-prod-1-master-1`
   1. `k3s-prod-1-master-2`
   1. `k3s-prod-1-master-3`
   2. `k3s-prod-1-worker-1`
   2. `k3s-prod-1-worker-2`
   2. `k3s-prod-1-worker-3`
1. For testing:. 
   1. `k3s-test-1-master-1`
   2. `k3s-test-1-worker-1`
   3. `k3s-test-1-worker-2`
   4. `k3s-test-1-worker-3`

## Kubernetes Resources

Kubernetes resouces are deployed and managed separately through [nix-config/pulumi/k8s/](../../pulumi/k8s/).

[k3s]: https://github.com/k3s-io/k3s/
[what-have-k3s-removed-from-upstream-kubernetes]: https://github.com/k3s-io/k3s/?tab=readme-ov-file#what-have-you-removed-from-upstream-kubernetes

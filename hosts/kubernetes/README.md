# Kubernetes Clusters

> WIP, not finished yet.

I'm running two Kubernetes clusters, one for production and one for testing.

I prefer to use [k3s] as the Kubernetes distribution, because it's lightweight, easy to install, and full featured(see [what-have-k3s-removed-from-upstream-kubernetes] for details).

## Hosts

1. For production:
   1. `k3s-prod-master-1`
   2. `k3s-prod-worker-1`
   2. `k3s-prod-worker-2`
   2. `k3s-prod-worker-3`
1. For testing:. 
   1. `k3s-test-master-1`
   2. `k3s-test-worker-1`
   3. `k3s-test-worker-2`
   4. `k3s-test-worker-3`

[k3s]: https://github.com/k3s-io/k3s/
[what-have-k3s-removed-from-upstream-kubernetes]: https://github.com/k3s-io/k3s/?tab=readme-ov-file#what-have-you-removed-from-upstream-kubernetes

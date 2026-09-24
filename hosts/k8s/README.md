# Kubernetes Clusters

> WIP, not finished yet.

I'm running a Kubernetes cluster for testing and development.

I prefer to use [k3s] as the Kubernetes distribution, because it's lightweight, easy to install, and
full featured(see [what-have-k3s-removed-from-upstream-kubernetes] for details).

## VM Cluster

The VM cluster is running on physical machines; all my virtual machines run on these hosts,
including the `k3s-test-1` cluster.

## K3s Clusters

The control plane runs as NixOS **microVMs** ([microvm.nix]) on the physical hosts. Each guest keeps
its state in three sparse ext4 images under the host's `/var/lib/microvms/<name>/`:

- `etc.img` (64M) — the ssh host key (also the agenix age identity) and `machine-id`
- `var.img` (20G) — k3s state (`/var/lib/rancher/k3s`) and the NixOS uid/gid maps
- `home.img` (4G) — the user's home

The guest's root is a tmpfs and `/nix/store` is the host's store shared read-only (virtiofs), so no
image has to be built or uploaded; only the volumes above persist. The guest's tap interface is
bridged onto `br0`, and its name is derived from the guest IP (e.g. `192.168.5.114` -> `vm114`, as
`IFNAMSIZ` caps interface names at 15 characters).

### Updating a running guest

Deploy a guest with the repository's `just` recipe. It evaluates the guest locally, transfers the
complete Nix closure to the physical host, installs it under `/var/lib/microvms/<name>`, and
activates the guest:

```sh
just microvm-deploy <guest> <physical-host> <guest-ip>
```

For example, `just microvm-deploy k3s-test-1-master-3 shushou 192.168.5.116`.
The recipe installs the runner on the physical host first, then activates the guest with
the microvm.nix SSH deployment interface.

Use `just build-microvm <guest>` to build a runner without deploying it. Do not replace the guest
recipe with a manual symlink operation.

Do not point `/var/lib/microvms/<name>/current` at a store path built on another machine. Nix store
paths are local until their closure is copied to the target host, and a missing runner makes the
systemd unit skip startup. Do not delete or recreate `etc.img`, `var.img`, or `home.img`; these
images hold the guest identity and K3s state.

For a cluster rollout, deploy one guest at a time. Before each restart, record the active runner
and verify that the new runner exists on the physical host. After each restart, wait for the guest
Node to become `Ready`, then check the API VIP `/readyz`, Cilium, storage CSI, and any workload
health gates. If a gate fails, restore the recorded runner through the same host access path and
start the guest service before proceeding to the next node.

To move an existing VM over in place, copy the host key and `machine-id` from its disk into
`etc.img`, and `/var/lib/rancher/k3s/server` into `var.img`, **before the first boot** — then it
keeps its identity and etcd membership instead of bootstrapping a new cluster.

1. `k3s-test-1-master-{1,2,3}` — control plane, running as microVMs; tainted
   `node-role.kubernetes.io/control-plane:NoSchedule`
1. `k3s-test-1-worker-{1,2,3}` — workloads, running as microVMs

Placement: `worker-1` (4 vCPU / 16 GiB) runs on `shoryu`; `worker-2` (4 vCPU / 16 GiB) and
`worker-3` (2 vCPU / 8 GiB) run on `shushou`. `youko` has no worker because it has the least free
memory and also runs the homelab services.

The master taint comes from kubelet's `registerWithTaints`, which only takes effect when the Node
object is first created. These masters are long-lived and predate the config, so the taint was
applied once by hand
(`kubectl taint nodes <name> node-role.kubernetes.io/control-plane=:NoSchedule`); a node rebuilt
from scratch gets it automatically. The workers carry no `node-role.kubernetes.io/worker` label:
kubelet refuses to self-assign the reserved `node-role.kubernetes.io/*` labels via `--node-label`,
and placement is enforced by the control-plane taint instead.

## TODO / Known issues

- **The USB HDD bridge is flaky.** youko's two HDDs sit behind a JMicron JMS567 USB-SATA bridge that
  keeps resetting (`dmesg` on `youko`). Find out how often it resets and how much it matters before
  putting anything critical (e.g. an NFS export) on it.

## Kubernetes Resources

Kubernetes resources are deployed and managed separately through
[ryan4yin/k8s-gitops](https://github.com/ryan4yin/k8s-gitops).

[k3s]: https://github.com/k3s-io/k3s/
[microvm.nix]: https://github.com/microvm-nix/microvm.nix
[what-have-k3s-removed-from-upstream-kubernetes]:
  https://github.com/k3s-io/k3s/?tab=readme-ov-file#what-have-you-removed-from-upstream-kubernetes

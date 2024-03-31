## How to create & managage KubeVirt's Virtual Machine from this flake?

Use `aquamarine` as an example, we can create a virtual machine with the following command:

```shell
just upload-vm aquamarine
```

Then create the virtual machine by creating a yaml file at
[ryan4yin/k8s-gitops](https://github.com/ryan4yin/k8s-gitops/tree/main/vms)

Once the virtual machine `aquamarine` is created, we can deploy updates to it with the following
commands:

```shell
just col aquamarine
just col kubevirt-shoryu
just col k3s-test-1-master-1
```

If you're not familiar with remote deployment, please read this tutorial first:
[Remote Deployment - NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/best-practices/remote-deployment)

## How to create & manage VMs (the retired KubeVirt path)

> [!NOTE] KubeVirt is being retired. aquamarine runs natively on `youko` and the k3s-test
> nodes run as [microVMs](./hosts/k8s/README.md); this document only covers the VMs that
> are left to move (currently the Windows VM).

Use `aquamarine` as an example, first build and upload the virtual machine's qcow2 image to the file
server:

```shell
just upload-vm aquamarine
```

Then create the virtual machine by creating a yaml file at
[ryan4yin/k8s-gitops](https://github.com/ryan4yin/k8s-gitops/tree/main/vms), set the
`spec.dataVolumeTemplates[0].source.http.url` to the uploaded file's URL, and fluxcd will
automatically apply the changes, then a virtual machine named `aquamarine` will be created in the
VM cluster.

Once the virtual machine `aquamarine` is created, we can deploy updates to it with the following
commands:

```shell
just col aquamarine
just col shoryu

# Set a configuration for the next boot instead of switching immediately
just col aquamarine boot
```

If you're not familiar with remote deployment, please read this tutorial first:
[Remote Deployment - NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/best-practices/remote-deployment)

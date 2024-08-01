## How to create & managage KubeVirt's Virtual Machine from this flake?

Use `aquamarine` as an example, first build and upload the virtual machine's qcow2 image to the file
server:

```shell
just upload-vm aquamarine
```

Then create the virtual machine by creating a yaml file at
[ryan4yin/k8s-gitops](https://github.com/ryan4yin/k8s-gitops/tree/main/vms), set the
`spec.dataVolumeTemplates[0].source.http.url` to the uploaded file's URL, and fluxcd will
automatically apply the changes, then a virtual machine named `aquamarine` will be created in the
KubeVirt cluster.

Once the virtual machine `aquamarine` is created, we can deploy updates to it with the following
commands:

```shell
just col aquamarine
just col kubevirt-shoryu
just col k3s-test-1-master-1
```

If you're not familiar with remote deployment, please read this tutorial first:
[Remote Deployment - NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/best-practices/remote-deployment)

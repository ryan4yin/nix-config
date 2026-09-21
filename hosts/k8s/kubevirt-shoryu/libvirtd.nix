{
  pkgs,
  lib,
  mylib,
  ...
}:
let
  genXml = import (mylib.relativeToRoot "lib/genLibvirtDomainXml.nix") { inherit lib; };

  # Declarative libvirt domains. The disk image is a one-time copy (reflink) of
  # the VM's former KubeVirt disk, e.g.:
  #   cp --reflink=auto /var/lib/rancher/k3s/storage/vms/<vm>-disk/disk.img \
  #                     /var/lib/libvirt/images/<vm>.img
  domains = {
    idols-kana = {
      uuid = "e744f563-7c7d-45e6-bc71-61980790208d";
      vcpu = 4;
      memoryGiB = 8;
      disk = "/var/lib/libvirt/images/idols-kana.img";
      mac = "52:54:00:5a:51:02";
      vncPort = 5902;
    };
    idols-ruby = {
      uuid = "3a959d02-11de-498d-bce7-85f78713ca63";
      vcpu = 4;
      memoryGiB = 8;
      disk = "/var/lib/libvirt/images/idols-ruby.img";
      mac = "52:54:00:5a:51:03";
      vncPort = 5903;
    };
  };
in
{
  # libvirt/QEMU -- runs the VMs directly instead of on KubeVirt. Used for the
  # VMs that need to feel like a real machine (the agent desktops kana/ruby) and
  # for Windows.
  virtualisation.libvirtd.enable = true;

  # The VMs attach to our existing bridge (br0), so allow it explicitly.
  virtualisation.libvirtd.allowedBridges = [ "br0" ];

  # We don't want libvirt's NAT network (virbr0): every VM uses br0.
  systemd.services.libvirt-disable-default-net = {
    description = "Disable libvirt's default NAT network";
    after = [ "libvirtd.service" ];
    requires = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.libvirt}/bin/virsh net-destroy default || true
      ${pkgs.libvirt}/bin/virsh net-autostart --disable default || true
    '';
  };

  # Define (and autostart) the declarative domains on every activation.
  systemd.services.libvirt-define-domains = {
    description = "Define the declarative libvirt domains";
    after = [ "libvirtd.service" ];
    requires = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: args: ''
        ${pkgs.libvirt}/bin/virsh define ${
          pkgs.writeText "libvirt-domain-${name}.xml" (genXml (args // { inherit name; }))
        }
        ${pkgs.libvirt}/bin/virsh autostart ${name} || true
      '') domains
    );
  };

  # VM disk images (the declarative domains reference files here).
  systemd.tmpfiles.rules = [
    "d /var/lib/libvirt/images 0755 root root -"
  ];
}

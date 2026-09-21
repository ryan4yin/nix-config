{
  pkgs,
  ...
}:
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

  # VM disk images (the declarative domains reference files here).
  systemd.tmpfiles.rules = [
    "d /var/lib/libvirt/images 0755 root root -"
  ];
}

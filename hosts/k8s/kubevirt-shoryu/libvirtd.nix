{
  # libvirt/QEMU -- runs the VMs directly instead of on KubeVirt. Used for the
  # VMs that need to feel like a real machine (the agent desktops kana/ruby) and
  # for Windows.
  #
  # The VMs attach to our existing bridge (br0) via their own tap/MAC, so we do
  # not need libvirt's NAT network.
  #
  # NOTE: enabling this on a KubeVirt host may touch the network stack (libvirt
  # creates its own virbr0 by default) -- see hosts/README.md, "Deploying
  # KubeVirt hosts": if it restarts networkd, deploy with `boot` + a serial
  # reboot instead of `switch`.
  virtualisation.libvirtd.enable = true;

  # VM disk images (declarative domains reference files here).
  systemd.tmpfiles.rules = [
    "d /var/lib/libvirt/images 0755 root root -"
  ];
}

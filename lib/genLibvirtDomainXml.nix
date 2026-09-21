# Generate a libvirt domain XML for a VM that behaves like a real machine
# (BIOS/q35, virtio disk, bridged NIC, VNC display).
#
# The NIC is pinned to q35 PCI bus 0x02 and the disk to bus 0x04 so the guest
# sees the same interface name it did under the former KubeVirt (enp2s0) and the same
# device ordering.
{ lib }:
{
  name,
  uuid,
  vcpu,
  memoryGiB,
  disk,
  mac,
  bridge ? "br0",
  vncPort,
}:
''
  <domain type='kvm'>
    <name>${name}</name>
    <uuid>${uuid}</uuid>
    <memory unit='GiB'>${toString memoryGiB}</memory>
    <vcpu>${toString vcpu}</vcpu>
    <os>
      <type arch='x86_64' machine='q35'>hvm</type>
    </os>
    <features>
      <acpi/>
    </features>
    <cpu mode='host-passthrough'/>
    <clock offset='utc'/>
    <on_poweroff>destroy</on_poweroff>
    <on_reboot>restart</on_reboot>
    <devices>
      <disk type='file' device='disk'>
        <driver name='qemu' type='raw'/>
        <source file='${disk}'/>
        <target dev='vda' bus='virtio'/>
        <address type='pci' domain='0x0000' bus='0x04' slot='0x00' function='0x0'/>
      </disk>
      <interface type='bridge'>
        <mac address='${mac}'/>
        <source bridge='${bridge}'/>
        <model type='virtio'/>
        <address type='pci' domain='0x0000' bus='0x02' slot='0x00' function='0x0'/>
      </interface>
      <controller type='usb' model='qemu-xhci'/>
      <graphics type='vnc' listen='0.0.0.0' port='${toString vncPort}' autoport='no'/>
      <video>
        <model type='virtio'/>
      </video>
      <console type='pty'/>
      <serial type='pty'/>
      <rng model='virtio'>
        <backend model='random'>/dev/urandom</backend>
      </rng>
    </devices>
  </domain>
''

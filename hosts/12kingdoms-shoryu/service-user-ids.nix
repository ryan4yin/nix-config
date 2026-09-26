{
  ...
}:
{
  # Service users/groups are created by their modules with a dynamically
  # allocated uid/gid. That allocation is not stable when the set of system
  # users changes, while files on the persistent volumes keep the old numeric
  # owner.
  #
  # microvm runs the k3s guest VMs and owns their persistent state images
  # (/var/lib/microvms/<name>/{etc,var,home}.img). After its uid shifted, qemu
  # could no longer open the images and the guests failed to start on boot with
  # "Could not open 'etc.img': Permission denied". Pin it to the value the
  # on-disk images use. The ids are host-specific, so this lives in the host
  # config rather than a shared module.
  users.users.microvm.uid = 997;
}

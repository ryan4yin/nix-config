{
  ...
}:
let
  # Shared golden-image store for the VM cluster. It is exported over
  # NFSv4 so the cluster's NFS CSI driver can hand out RWX volumes to every
  # node, and VM disks are cloned from it into local-path.
  #
  # It lives on the encrypted btrfs pool (/persistent), which has plenty of
  # free space on this host.
  goldenDir = "/persistent/nfs/golden";

  # Only the homelab LAN may mount the export; the VM hosts and the k3s nodes
  # (which run the NFS-CSI node plugin) are all on it. The store is not
  # sensitive, so the whole LAN is fine rather than an explicit client list.
  clientCidr = "192.168.5.0/24";
in
{
  # Make sure the export directory exists before the NFS server starts.
  systemd.tmpfiles.rules = [
    "d ${goldenDir} 0755 root root -"
  ];

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    ${goldenDir} ${clientCidr}(rw,sync,no_subtree_check,fsid=0,no_root_squash)
  '';

  # NFSv4 only needs 2049/tcp (no rpcbind/mountd/statd). The export is limited
  # to the LAN, and the shared firewall trusts the LAN.
}

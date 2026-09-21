{
  ...
}:
let
  # Shared golden-image store for the KubeVirt cluster. It is exported over
  # NFSv4 so the cluster's NFS CSI driver can hand out RWX volumes to every
  # node, and VM disks are cloned from it into local-path.
  #
  # It lives on the encrypted btrfs pool (/persistent), which has plenty of
  # free space on this host.
  goldenDir = "/persistent/nfs/golden";

  # Only the homelab LAN may mount the export. The KubeVirt nodes are the
  # clients (the CSI node plugin mounts from the node, not from the pod).
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

  # NFSv4 only needs 2049/tcp (no rpcbind/mountd/statd), so the firewall stays
  # minimal. The export itself is already restricted to the LAN CIDR above.
  networking.firewall.allowedTCPPorts = [ 2049 ];
}

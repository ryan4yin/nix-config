{
  myvars,
  lib,
  ...
}:
let
  # Shared golden-image store for the VM cluster. It is exported over NFSv4 so
  # the cluster's NFS CSI driver can hand out RWX volumes to every node, and VM
  # disks are cloned from it into local-path.
  #
  # It lives on the encrypted btrfs pool (/persistent), which has plenty of
  # free space on this host.
  goldenDir = "/persistent/nfs/golden";

  # Only the hosts that actually mount the export may reach it: every k3s node
  # runs the NFS CSI node plugin, and the VM hosts clone golden disks by hand.
  # The rest of the LAN is not a client.
  k3sNodes = lib.filterAttrs (name: _: lib.hasPrefix "k3s-test-1-" name) myvars.networking.hostsAddr;
  clients = [
    myvars.networking.hostsAddr.shoryu.ipv4
    myvars.networking.hostsAddr.shushou.ipv4
    myvars.networking.hostsAddr.youko.ipv4
  ]
  ++ lib.mapAttrsToList (_: v: v.ipv4) k3sNodes;

  exportOpts = "rw,sync,no_subtree_check,fsid=0,no_root_squash";
in
{
  # Make sure the export directory exists before the NFS server starts.
  systemd.tmpfiles.rules = [
    "d ${goldenDir} 0755 root root -"
  ];

  services.nfs.server.enable = true;
  services.nfs.server.exports = lib.concatStringsSep "\n" (
    map (client: "${goldenDir} ${client}(${exportOpts})") clients
  );

  # NFSv4 only needs 2049/tcp (no rpcbind/mountd/statd). The export is limited
  # to the hosts above, not the whole LAN. `no_root_squash` stays until the
  # existing root-owned PVC subdirectories are migrated for `root_squash`; see
  # SECURITY.md.
}

{
  fileSystems."/mnt/utm" = {
    device = "share"; # 9p tag name from UTM/QEMU configuration
    fsType = "9p"; # Virtio-9p filesystem type
    options = [
      "trans=virtio" # Use virtio transport for paravirtualized I/O
      "version=9p2000.L" # 9P protocol version (best Linux compatibility)
      "ro" # Read-only access
      "_netdev" # Mark as network-dependent (waits for network)
      "nofail" # Don't fail boot if mount fails
      "auto" # Mount automatically with -a

      # Ownership mapping - all files appear as specified user/group
      "uid=1000" # Map to user ID 1000
      "gid=1000" # Map to group ID 100
    ];
  };
}

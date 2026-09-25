{
  ...
}:
{
  # Service users/groups are created by their modules with a dynamically
  # allocated uid/gid. That allocation is not stable when the set of users
  # changes -- adding the `immich` user shifted gitea from 993:985 to 996:993
  # and rustfs from 987:977 to 988:983 -- while files on the persistent volumes
  # keep the old numeric owner. The service then loses access to its own data
  # (gitea and rustfs failed to start this way after a restart).
  #
  # Pin every dynamically allocated id on this host to its current value so it
  # can never shift again. The ids are host-specific (other hosts already have
  # their own values and data), so this lives in the host config rather than a
  # shared module.
  users.users = {
    jellyfin.uid = 984;
    sftpgo.uid = 987;
    rustfs.uid = 988;
    redis-shared.uid = 989;
    postgres-exporter.uid = 990;
    node-exporter.uid = 992;
    microvm.uid = 993;
    immich.uid = 994;
    homepage.uid = 995;
    gitea.uid = 996;
    btrbk.uid = 997;
    avahi.uid = 998;
    acme.uid = 999;
  };

  users.groups = {
    jellyfin.gid = 974;
    wireshark.gid = 975;
    victoriametrics-data.gid = 976;
    uinput.gid = 977;
    sftpgo.gid = 981;
    ryan.gid = 982;
    rustfs.gid = 983;
    redis-shared.gid = 984;
    postgres-exporter.gid = 985;
    podman.gid = 986;
    plugdev.gid = 987;
    node-exporter.gid = 989;
    immich.gid = 990;
    homepage.gid = 991;
    grafana.gid = 992;
    gitea.gid = 993;
    fileshare.gid = 994;
    docker.gid = 995;
    btrbk.gid = 996;
    avahi.gid = 997;
    adbusers.gid = 998;
    acme.gid = 999;
  };
}

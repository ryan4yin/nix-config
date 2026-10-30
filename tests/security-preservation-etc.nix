{ pkgs, preservation }:
# `/etc` entries that carry a mode are *copied* into /etc by stage-2
# activation (setup-etc.pl), which runs before systemd. preservation mounts a
# persisted directory only after systemd starts, so a persisted /etc/ssh
# shadows the fresh copies and sshd keeps reading the previous `switch`.
#
# This boots a VM with /etc/ssh persisted from a separate disk and checks that
# the declared authorized_keys file reached the persistent volume, which only
# happens when the mount is prepared in initrd.
pkgs.testers.runNixOSTest {
  name = "security-preservation-etc";

  nodes.machine =
    { lib, ... }:
    {
      imports = [ preservation.nixosModules.default ];

      virtualisation.emptyDiskImages = [ 256 ];
      virtualisation.memorySize = 1024;

      fileSystems."/persistent" = {
        device = "/dev/vdb";
        fsType = "ext4";
        autoFormat = true;
        neededForBoot = true;
      };

      preservation.enable = true;
      preservation.preserveAt."/persistent".directories = [
        {
          directory = "/etc/ssh";
          inInitrd = true;
        }
      ];

      services.openssh.enable = true;
      users.users.alice = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAITestOnlyKeyMaterial000000000000000000000 test@example"
        ];
      };
    };

  testScript = ''
    # First boot only to get the persistent volume formatted.
    machine.start()
    machine.wait_for_unit("multi-user.target")

    # Seed a stale authorized_keys file, as a previous `switch` would have left
    # it, then reboot into the same generation with a different declared key.
    machine.succeed("mkdir -p /persistent/etc/ssh/authorized_keys.d")
    machine.succeed("echo 'ssh-ed25519 AAAAOld stale@example' > /persistent/etc/ssh/authorized_keys.d/alice")
    machine.succeed("chmod 444 /persistent/etc/ssh/authorized_keys.d/alice")
    machine.shutdown()

    machine.start()
    machine.wait_for_unit("multi-user.target")
    machine.succeed("mountpoint -q /etc/ssh")

    # The boot-time copy must land on the persistent volume and replace the
    # stale file; with the mount ordered after activation it stays stale.
    machine.succeed("grep -q test@example /persistent/etc/ssh/authorized_keys.d/alice")
    machine.fail("grep -q stale@example /etc/ssh/authorized_keys.d/alice")
    machine.succeed("grep -q test@example /etc/ssh/authorized_keys.d/alice")
    machine.succeed("test \"$(stat -c %a /etc/ssh/authorized_keys.d/alice)\" = 444")

    machine.wait_for_unit("sshd.service")
  '';
}

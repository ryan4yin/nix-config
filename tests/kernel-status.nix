{ pkgs }:
pkgs.testers.runNixOSTest {
  name = "kernel-status-textfile";
  nodes.machine = {
    imports = [ ../modules/nixos/base/kernel-status.nix ];
    services.prometheus.exporters.node = {
      enable = true;
      listenAddress = "127.0.0.1";
    };
    environment.systemPackages = [ pkgs.curl ];
    virtualisation.memorySize = 384;
  };
  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")
    machine.wait_for_unit("prometheus-node-exporter.service")
    # Test VMs boot without an installed system profile. Missing metadata must
    # be unknown, not a false healthy result; then model a real profile selection.
    machine.succeed("systemctl start nixos-kernel-status.service")
    machine.succeed("grep -Fx 'nixos_kernel_status_success 0' /run/nixos-kernel-status/kernel-status.prom")
    machine.fail("grep '^nixos_kernel_reboot_required ' /run/nixos-kernel-status/kernel-status.prom")
    machine.succeed("mkdir -p /nix/var/nix/profiles && ln -s /run/booted-system /nix/var/nix/profiles/system")
    machine.succeed("systemctl start nixos-kernel-status.service")
    machine.succeed("grep -Fx 'nixos_kernel_status_success 1' /run/nixos-kernel-status/kernel-status.prom")
    machine.succeed("grep -Fx 'nixos_kernel_reboot_required 0' /run/nixos-kernel-status/kernel-status.prom")
    print(machine.succeed("stat -Lc '%a %U:%G %n' /run/nixos-kernel-status /run/nixos-kernel-status/kernel-status.prom"))
    print(machine.succeed("namei -l /run/nixos-kernel-status/kernel-status.prom"))
    print(machine.succeed("systemctl show nixos-kernel-status.service prometheus-node-exporter.service -p User -p Group -p DynamicUser -p RuntimeDirectoryMode"))
    machine.succeed("curl -fsS http://127.0.0.1:9100/metrics | grep -Fx 'nixos_kernel_status_success 1'")
    machine.succeed("curl -fsS http://127.0.0.1:9100/metrics | grep -Fx 'nixos_kernel_reboot_required 0'")
    # Changing only the selected profile models a boot-only deployment: the
    # booted/current system stays unchanged, but the next kernel is different.
    machine.succeed("mkdir /run/kernel-status-fixture && touch /run/kernel-status-fixture/kernel && ln -sfn /run/kernel-status-fixture /nix/var/nix/profiles/system")
    machine.succeed("systemctl start nixos-kernel-status.service")
    machine.succeed("curl -fsS http://127.0.0.1:9100/metrics | grep -Fx 'nixos_kernel_reboot_required 1'")
    # A later metadata failure must replace old health/mismatch samples, rather
    # than leave them silently looking current at the exporter boundary.
    machine.succeed("rm /nix/var/nix/profiles/system && systemctl start nixos-kernel-status.service")
    machine.succeed("curl -fsS http://127.0.0.1:9100/metrics | grep -Fx 'nixos_kernel_status_success 0'")
    machine.fail("curl -fsS http://127.0.0.1:9100/metrics | grep '^nixos_kernel_reboot_required '")
  '';
}

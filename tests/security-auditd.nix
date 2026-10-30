{ pkgs, agenix }:
let
  # Throwaway age identity and secret, generated at build time for the VM.
  testSecrets = pkgs.runCommand "auditd-test-secrets" { nativeBuildInputs = [ pkgs.age ]; } ''
    mkdir $out
    age-keygen -o $out/key.txt
    echo not-a-real-secret | age -r "$(age-keygen -y $out/key.txt)" -o $out/secret.age
  '';
in
pkgs.testers.runNixOSTest {
  name = "security-auditd";
  nodes.machine =
    { config, ... }:
    {
      imports = [
        ../modules/nixos/base/auditd.nix
        agenix.nixosModules.default
      ];
      modules.security.audit.enable = true;
      services.openssh.enable = true;
      age.identityPaths = [ "${testSecrets}/key.txt" ];
      age.secrets.test-secret.file = "${testSecrets}/secret.age";
      users.users.alice.isNormalUser = true;
      environment.etc."audit-rule-count".text = toString (builtins.length config.security.audit.rules);
      virtualisation.memorySize = 1024;
    };
  testScript = ''
    import shlex

    def ssh(cmd):
        return machine.execute(
            "ssh -i /root/id -o StrictHostKeyChecking=no root@localhost " + shlex.quote(cmd)
        )

    # auditd writes asynchronously, so poll; `-ul 0` keeps records whose
    # login uid (auid) is root, i.e. from the SSH session. Without
    # --input-logs, ausearch reads stdin when it is not a terminal.
    def wait_logged(key, match, flags="", count=1):
        machine.wait_until_succeeds(
            f"test $(ausearch --input-logs -i -k {key} {flags} | grep -c -- {shlex.quote(match)}) -ge {count}"
        )

    machine.wait_for_unit("audit-rules-nixos.service")
    machine.wait_for_unit("auditd.service")
    machine.wait_for_unit("sshd.service")

    with subtest("every rule loads and auditing is enabled"):
        t.assertIn("enabled 1", machine.succeed("auditctl -s"))
        rules = machine.succeed("auditctl -l")
        t.assertEqual(len(rules.splitlines()), int(machine.succeed("cat /etc/audit-rule-count")))
        t.assertIn("-w /run/agenix.d -p rwa -k credential-access", rules)
        t.assertIn("-a never,task -F auid=-1", rules)

    # The test driver's shell is a service: this setup is not audited.
    machine.succeed(
        "ssh-keygen -q -t ed25519 -N ''' -f /root/id",
        "install -d -m 700 /root/.ssh",
        "cat /root/id.pub >> /root/.ssh/authorized_keys",
    )

    with subtest("an SSH root session logs its commands and secret reads"):
        ssh("cat /run/agenix/test-secret; ${pkgs.hello}/bin/hello")
        wait_logged("root-session", "hello", "-ul 0")
        # sshd is built without libaudit; PAM records the login and its address.
        machine.succeed("ausearch --input-logs -i -m USER_START -ul 0 | grep -q 'addr=::1 terminal=ssh'")
        wait_logged("credential-access", "name=/run/agenix/test-secret", "-ul 0")

    with subtest("a service is not audited; the same actions from a session are"):
        machine.succeed(
            "systemd-run --wait -p Environment=PATH=${pkgs.coreutils}/bin ${pkgs.runtimeShell} -c "
            "'cat /run/agenix/test-secret >/dev/null; touch /etc/ssh/from-service'"
        )
        ssh("cat /run/agenix/test-secret >/dev/null; touch /etc/ssh/from-session")
        wait_logged("ssh-config", "from-session", "-ul 0")
        wait_logged("credential-access", "name=/run/agenix/test-secret", "-ul 0", count=2)
        machine.succeed("test -e /etc/ssh/from-service")
        machine.fail("ausearch --input-logs -i -k ssh-config | grep -q from-service")
        # auditctl's own rule loads also carry the key (CONFIG_CHANGE, no auid).
        machine.fail("ausearch --input-logs -i -k credential-access | grep auid=unset | grep -q comm=cat")
        machine.fail("ausearch --input-logs -i -k root-session | grep -q from-service")
        # systemd-executor opens the agenix mount point with O_PATH while it
        # builds a sandboxed unit's namespace; it has no auid either.
        machine.succeed("systemctl restart nscd")
        machine.fail("ausearch --input-logs -i -k credential-access | grep -q comm=.nsncd")

    with subtest("the agenix watch survives a new secrets generation"):
        machine.succeed("/run/current-system/activate")
        machine.succeed("readlink /run/agenix | grep -q '/2$'")
        ssh("cat /run/agenix/test-secret >/dev/null")
        wait_logged("credential-access", "name=/run/agenix/test-secret", "-ul 0", count=3)

    with subtest("denials in a login session are recorded"):
        ssh("su alice -s /bin/sh -c 'cat /etc/shadow'")
        wait_logged("access-denied", "shadow", "-ul 0")

    with subtest("auditd keeps its log; the journal keeps a copy"):
        machine.succeed("test -s /var/log/audit/audit.log")
        machine.succeed("journalctl _TRANSPORT=audit -q | grep -q root-session")
  '';
}

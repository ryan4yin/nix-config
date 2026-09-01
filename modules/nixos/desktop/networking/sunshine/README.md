# Temporary remote session recovery

When a remote-only machine is stuck at the `greetd` TUI, run the Nushell helper from an
SSH session to start one complete PAM/logind Wayland session without changing
the persistent NixOS configuration:

```bash
sudo nu ./remote-session.nu
```

The helper stops the normal `greetd` service, starts a temporary systemd-managed
`greetd` configuration on `/dev/tty1`, and runs the invoking user's
`~/.wayland-session`. It removes the temporary configuration when the process
exits. Tailscale is a system service and is not stopped.

Options:

```text
-u USER       session user (defaults to SUDO_USER)
-t TTY        tty device, for example /dev/tty2
-c COMMAND    Wayland session command (defaults to ~/.wayland-session)
```

Keep the SSH terminal open while the temporary session runs. A reboot or a
manual restart of `greetd.service` restores the normal TUI configuration.

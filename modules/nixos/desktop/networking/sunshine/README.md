# Temporary remote session recovery

When a remote-only machine is stuck at the `greetd` TUI, run the Nushell helper from an
SSH session to start one complete PAM/logind Wayland session without changing
the persistent NixOS configuration:

```bash
sudo nu ./remote-session.nu
```

The helper validates its dependencies before changing the current session. It
then stops the normal `greetd` service, starts a transient systemd-managed
`greetd` configuration on `/dev/tty1`, and runs Niri directly. It returns after
greetd, Niri, and Sunshine are ready. Tailscale is not affected.

The `Virtual-1` output is created persistently by the `vkms` configuration in
`hosts/idols-ai/hardware-intel.nix` and configured by
`hosts/idols-ai/niri-hardware.kdl`. It gives Niri and Sunshine a capture target
when both physical monitors attached to the NVIDIA GPU are off. The output also
exists during normal physical sessions; keeping an idle virtual framebuffer has
minor GPU and memory overhead.

Options:

```text
-u USER       session user (defaults to SUDO_USER)
-t TTY        tty device, for example /dev/tty2
-c COMMAND    Wayland session command (defaults to niri --session)
-f, --force   replace an existing Niri session without confirmation
--check       validate prerequisites without changing service state
```

A reboot or a manual restart of `greetd.service` restores the normal TUI
configuration.

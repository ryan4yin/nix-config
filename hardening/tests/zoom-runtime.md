# Zoom nested runtime verification

The Zoom 7.2.1.5760 candidate built and opened two `Zoom Workplace` X11 windows on the NVIDIA
desktop. The final tested output was
`/nix/store/yy6sxsgn5rqafvvgs3k53akwqjcfa2r7-nixpak-zoom-7.2.1.5760`.

The live main process had `NoNewPrivs: 1`, a network namespace different from the host, and
`/.flatpak-info` with `name=us.zoom.Zoom`. Its ancestry included ZoomLauncher and the nested
bubblewrap processes. Its `/dev` contained only standard synthetic devices, `dri`, `nvidia0`,
`nvidiactl`, `nvidia-modeset`, and `nvidia-uvm`; no camera, USB or block devices were exposed.
Zoom's main process reported `Seccomp: 0`; this test does not establish a renderer seccomp
guarantee.

The upstream FHS runtime remains intact. Its automatic root mounts propagate directories, so the
wrapper explicitly propagates the outer `/.flatpak-info` file for portal identification. Its `/dev`
bind inherits the outer sandbox's filtered devices. The outer network uses pasta isolate mode,
without host loopback sharing. X11 remains a display trust boundary: explicit ScreenCast portal
permission does not prevent access through the X11 connection.

Initial display testing found that `/tmp` tmpfs shadowed the X11 socket and that NVIDIA OpenGL
needed the four device mappings now in `desktop-base.nix`. Zoom therefore keeps the sandbox's
private root `/tmp` instead of mounting another tmpfs over the socket, and explicitly passes
`DISPLAY` and `XAUTHORITY`.

## Repeat without touching the normal Zoom profile

Build the candidate without activating a host, then substitute its output path below. The temporary
home must be outside `/tmp` when testing policies that mount a `/tmp` tmpfs. Keep the current
display and session bus environment.

```bash
zoom_probe_dir=$(mktemp -d "$HOME/.cache/zoom-nixpak-probe.XXXXXX")
mkdir -p "$zoom_probe_dir"/{.config,.cache,.local/share,.local/state,Documents,Downloads}
HOME="$zoom_probe_dir" \
XDG_CONFIG_HOME="$zoom_probe_dir/.config" \
XDG_CACHE_HOME="$zoom_probe_dir/.cache" \
XDG_DATA_HOME="$zoom_probe_dir/.local/share" \
XDG_STATE_HOME="$zoom_probe_dir/.local/state" \
timeout --kill-after=3 30 /nix/store/OUTPUT/bin/zoom
```

While it runs, inspect the exact test process through `/proc/PID/root/dev`,
`/proc/PID/root/.flatpak-info`, `/proc/PID/ns/net`, `/proc/PID/status`, and its parent processes. Do
not sign in or join a meeting during this smoke test. The timeout terminates the owned launcher and
its sandbox. Confirm the test windows and processes are gone afterward.

The disposable run created `zoomus.conf` under the private application config directory. Existing
host `zoomus.conf` and `zoom.conf` are individually mounted when present. Application caches use the
private application cache directory.

Still pending: login and meeting join, microphone and speaker routing, camera portal behavior on
supported hardware, screencast selection and PipeWire FD handoff, recording/export paths, file
chooser access, URL opening and IME. No successful camera, audio or screencast session is claimed by
this smoke test.

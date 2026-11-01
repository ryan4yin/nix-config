# Runtime validation

Nixpak wrappers are accepted in three layers:

1. **Policy/build:** `just test` evaluates every wrapper and [`policy.nix`](policy.nix) rejects
   broad mounts, system D-Bus, keyring access and device grants outside each app's declared scope.
2. **Disposable smoke test:** [`verify-chromium.py`](verify-chromium.py) launches a Chromium-family
   wrapper with a temporary HOME and validates renderer sandboxing, environment clearing, bind
   scope, profile persistence and loopback policy.
3. **Interactive desktop check:** launch the real app, use its normal file/network/device workflows,
   and confirm the sandbox does not break required integration.

## Current status

| App                    | Policy/build | Runtime                                                           |
| ---------------------- | ------------ | ----------------------------------------------------------------- |
| Firefox                | Pass         | Interactive pass; camera/remote sharing intentionally unavailable |
| Chromium               | Pass         | Automated smoke + interactive pass                                |
| Chrome                 | Pass         | Interactive pass                                                  |
| Brave Origin           | Pass         | Interactive pass; backup browser without media grants             |
| Edge                   | Pass         | Interactive pass; backup browser without media grants             |
| Zoom                   | Pass         | Interactive pass                                                  |
| QQ / Telegram          | Pass         | Interactive startup/tray pass                                     |
| WeChat (native nixpak) | Pass         | Interactive Wayland validation pending                            |
| Foliate                | Pass         | Interactive validation pending                                    |
| Krita                  | Pass         | Interactive validation pending                                    |
| Bambu Studio           | Pass         | Interactive pass; device_page/filament UI unavailable in nixpkgs  |
| OrcaSlicer             | Pass         | Interactive pass; blank WebKit home page fixed                    |
| Remmina                | Pass         | Interactive validation pending                                    |
| OBS Studio             | Pass         | Interactive pass; NVENC recording and local RTMP streaming work   |
| Blender                | Pass         | Interactive validation pending                                    |
| MuseScore              | Pass         | Interactive launch pass; ALSA routed to default PipeWire sink     |
| mpv                    | Pass         | Interactive validation pending                                    |
| imv                    | Pass         | Interactive validation pending                                    |

Intentional exceptions:

- **Chromium** keeps host loopback and personal files for local development. Firefox has the same
  exception. Chrome, Brave Origin and Edge use pasta-isolated loopback.
- **Brave Origin and Edge are backup browsers.** They intentionally have no PulseAudio, Camera,
  ScreenCast or MPRIS grants.
- **Firefox camera and remote screen sharing are intentionally disabled.** Firefox does not support
  the XDG Camera/ScreenCast portal path used here, so enabling them would require granting raw video
  devices or the direct PipeWire socket. We deliberately do not grant those privileges.

Known packaging limitations:

- **Bambu Studio:** the nixpkgs build removes the `device_page` frontend build, so
  `share/BambuStudio/web/device_page/dist` is missing and filament management cannot load.
- **Bambu Studio:** the MakerWorld sidebar entry requires `firstguide.finish = "true"` in
  `BambuStudio.conf`; the upstream guide writes `"1"` while the web-view code only accepts `"true"`.
- **Bambu Studio:** the startup splash can render black under XWayland. This is cosmetic; the main
  UI renders normally.
- **MuseScore:** uses Qt's XCB backend, so it runs through XWayland. Its ALSA driver uses the host
  `pcm.!default` configuration, which forwards to PipeWire; this requires the raw PipeWire socket.
  Launch and audio routing pass, but audible playback and score/print/export workflows still need
  user confirmation.

## Browser smoke test

Build a wrapper from the locked inputs:

```bash
APP=chromium nix build --impure --out-link "browser-validation/$APP" --expr '
  let
    flake = builtins.getFlake (toString ./.);
    pkgs = import flake.inputs.nixpkgs {
      system = builtins.currentSystem;
      config.allowUnfree = true;
    };
  in
  pkgs.callPackage (./hardening/nixpaks + "/${builtins.getEnv "APP"}.nix") {
    mkNixPak = flake.inputs.nixpak.lib.nixpak { inherit pkgs; inherit (pkgs) lib; };
  }
'
python3 hardening/tests/verify-chromium.py "browser-validation/$APP/bin/$APP"
```

The script writes its disposable HOME under `/var/tmp`; the sandbox's private `/tmp` would otherwise
hide profile binds. Pasta-wrapped browsers also require a usable `/dev/net/tun` on the host. The
script checks live renderer `Seccomp=2` and `NoNewPrivs=1`, absence of `--no-sandbox`, canary-free
environments, effective bwrap arguments, profile persistence and loopback reachability.

Chromium-family browsers use the app-scoped Secret portal for v12 cookie encryption; they do not
receive `org.freedesktop.secrets`. If the portal is unavailable, Chromium can fall back to weaker
v10 storage; monitor `Local State.os_crypt.portal.prev_init_success`. Firefox uses NSS storage
instead. Browserpass separately exposes the password store and GPG-agent socket to
Firefox/Chromium/Chrome only.

## Zoom

Zoom keeps its upstream FHS runtime inside the outer nixpak boundary. The nested sandbox propagates
`/.flatpak-info`, uses pasta-isolated networking, and binds only `DISPLAY`, `XAUTHORITY`,
`/dev/video0`, `/dev/video1`, DRM sysfs and the declared app directories. X11 remains a
shared-display trust boundary: ScreenCast portal permission does not prevent capture through the X11
connection. Interactive login, audio, camera, screen sharing and file workflows passed.

## OBS

Interactive validation covered PipeWire screen capture, V4L2 camera capture, desktop/microphone
audio, NVENC H.264 Hybrid MP4 recording and RTMP publishing. Streaming was tested against a
temporary MediaMTX server on the host's LAN address; the OBS pasta namespace cannot reach host
loopback. Bilibili or another external provider still needs a real account-specific stream key to
validate provider authentication and CDN ingest.

OBS records to the path configured under output settings. In Simple mode that is
`SimpleOutput.FilePath`; Advanced mode uses `AdvOut.RecFilePath` and `AdvOut.FFFilePath`. These must
point at a writable bind such as `~/Videos`, not the sandbox's transient home root.

## Commands

```bash
just fmt
just test
git diff --check
ruff format --check hardening/tests/verify-chromium.py
ruff check hardening/tests/verify-chromium.py
prettier --check hardening/tests/runtime-validation.md
```

# Linux Hardening

Deployed and interactively validated on the Linux desktop host (2026-10-31). Policy and limits:
[SECURITY.md](../SECURITY.md).

## Shared boundaries

- Cleared environment; filtered session D-Bus; private `/dev/shm`; per-app `/tmp`. Chromium-family
  browsers share an app-specific `/tmp` so external URLs reuse one browser instance.
- Read-only `/nix/store`; GPU and display; fonts and themes; LAN and Internet.
- Portals for file chooser, URI opening, notifications, input methods and document exports.
- No whole host home, system D-Bus, SSH agent, USB/serial, raw camera or raw PipeWire socket.
- Host loopback only for Firefox/Chromium; all other apps use pasta-isolated loopback. Chromium is
  an intentional development exception. Brave Origin and Edge are backup browsers and receive no
  media grants.

## App permissions

`Media` means audio playback, microphone, Camera and ScreenCast portals. Writable paths are listed
explicitly; other files use the document portal. Every app also has private writable state.

| App          | Network       | Writable paths                                                                        | Grants                                                                                       |
| ------------ | ------------- | ------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Firefox      | Host loopback | `~/.mozilla`, personal files, Trash, Firefox artwork                                  | Audio, browserpass, MPRIS, idle; camera/screen sharing intentionally unavailable             |
| Chromium     | Host loopback | `~/.config/chromium`, personal files                                                  | Media, browserpass, MPRIS, idle, v12 Secret                                                  |
| Chrome       | Isolated      | `~/.config/google-chrome`, Downloads                                                  | Media, browserpass, MPRIS, idle, v12 Secret                                                  |
| Brave Origin | Isolated      | `~/.config/BraveSoftware/Brave-Origin`, Downloads                                     | v12 Secret                                                                                   |
| Edge         | Isolated      | `~/.config/microsoft-edge`, Downloads                                                 | v12 Secret                                                                                   |
| QQ           | Isolated      | Personal files, private app state                                                     | Media, notifications, tray, MPRIS, idle, accessibility                                       |
| Telegram     | Isolated      | Personal files, private app state                                                     | Media, notifications, tray, MPRIS, idle, accessibility, Ayatana indicators                   |
| Zoom         | Isolated      | `~/.zoom`, `zoomus.conf`, `zoom.conf`, Downloads, `Documents/Zoom`, private app state | Media, X11/XWayland, FHS, SNI tray, idle, `/dev/video0-1`, read-only `/sys/class/drm`        |
| WeChat       | Isolated      | Documents, Downloads, app-scoped `wechat` data, private app state                     | Media, Wayland, X11 fallback, SNI tray, file chooser portal                                  |
| Foliate      | None          | Documents/Downloads/Pictures read-only, app-scoped state                              | File chooser, OpenURI, notifications, IME, accessibility                                     |
| Krita        | None          | Documents/Downloads/Pictures writable, app-scoped state                               | File chooser, OpenURI, print, inhibit, notifications, IME, accessibility                     |
| Bambu Studio | Isolated      | Documents/Downloads/Pictures writable, app-scoped state                               | X11/XWayland, PulseAudio, cloud/LAN network, file chooser, notifications, IME, accessibility |
| OrcaSlicer   | Isolated      | Documents/Downloads/Pictures writable, app-scoped state                               | X11/XWayland, cloud/LAN network, file chooser, notifications, IME, accessibility             |
| Remmina      | Isolated      | `~/.config/remmina`, `~/.local/share/remmina`, `~/.remmina`, Downloads                | PulseAudio, SSH agent, file chooser, OpenURI, notifications, IME, accessibility              |
| OBS Studio   | Isolated      | `~/.config/obs-studio`, Videos/Pictures/Downloads                                     | ScreenCast, Camera, PulseAudio, tray, notifications, IME, accessibility                      |
| Blender      | Isolated      | `~/.config/blender`, Documents/Downloads/Pictures/Videos                              | X11/XWayland, PulseAudio, notifications, IME, accessibility                                  |
| MuseScore    | Isolated      | `~/.config/MuseScore`, `~/.local/share/MuseScore`, Documents/Downloads/Music/Pictures | PulseAudio, ALSA sequencer, print, notifications, IME, accessibility                         |
| mpv          | Isolated      | `~/.config/mpv`, `~/.cache/mpv`, `~/.local/state/mpv`; media dirs read-only           | MPRIS, file chooser, OpenURI                                                                 |
| imv          | None          | `~/.config/imv`; Documents/Downloads/Pictures read-only                               | File chooser, OpenURI                                                                        |

All browsers get read-only NSS certificates, printing, native notifications and accessibility.

## Browser secrets

- Chromium family: app-scoped Secret portal only. `SecretPortalKeyProviderUseForEncryption` writes
  v12 cookies; no `org.freedesktop.secrets` or broad keyring access.
- If the Secret portal is unavailable, Chromium can fall back to v10. Monitor
  `Local State.os_crypt.portal.prev_init_success`.
- Firefox uses NSS: `key4.db` and `logins.json` for logins, `cookies.sqlite` for cookies. It has no
  Secret portal or keyring grant. A Primary Password protects saved logins, not cookies.
- browserpass is separate: it exposes the password store and GPG-agent socket, not cookie
  encryption.
- Bookmarks, history, localStorage, IndexedDB and extension data remain readable by the browser.
  nixpak isolates them from other apps, not from browser compromise.

## Limits

- X11: Zoom and WeChat have shared-display trust; portal permissions cannot enforce portal-only
  capture.
- PulseAudio grants recording authority. Read-only GPG sockets still permit signing and decryption.
- pasta isolates loopback, not LAN access. Chromecast discovery is unverified.
- Brave Origin and Edge intentionally have no PulseAudio, Camera, ScreenCast or MPRIS grants. They
  are backup browsers, not media browsers.
- Firefox camera and remote screen sharing are intentionally disabled. Firefox does not support the
  XDG Camera/ScreenCast portal path used here, so granting camera or screen-capture access would
  require widening the sandbox with raw `/dev/video*` or direct PipeWire access. We choose not to
  grant that privilege.
- Bambu Studio's nixpkgs build omits the `device_page` frontend bundle, so filament management is
  unavailable. Its MakerWorld sidebar entry also requires the upstream `firstguide.finish = "true"`
  workaround; the startup splash may render black under XWayland.
- Remmina's SSH Tunnel support receives a read-only SSH agent socket and SSH client config. A
  compromised Remmina can use the agent to sign or decrypt while the agent is running.
- OBS, Blender, MuseScore and mpv use pasta-isolated networking. Host loopback services are not
  reachable unless the app is changed to a host-loopback exception.

## Validation

- Passed: `just fmt`, `just test`, `ai-niri` build, `shoukei-niri` eval and all wrapper builds.
- Interactive validation passed for Firefox, Chrome, Chromium, Brave Origin, Edge, QQ, Telegram,
  Zoom, Bambu Studio and OrcaSlicer. Chromium's host-loopback/personal-file exception and the
  Brave/Edge no-media policy are intentional.
- Wrappers for Remmina, OBS Studio, Blender, MuseScore, mpv and imv build and pass the policy suite;
  interactive validation is still pending.
- Chromium smoke test passed: renderer sandbox, environment clearing, bind scope, disposable-profile
  persistence and loopback policy.
- WeChat uses the native nixpkgs-patched package with nixpak as the only bwrap layer. Build/policy
  pass; interactive Wayland validation is still pending.
- Evidence and repeat commands: [runtime validation](tests/runtime-validation.md),
  [policy test](tests/policy.nix), which auto-loads every suite under [tests/policy](tests/policy/).

## Code map

- [nixpaks/](nixpaks/): wrappers and Home Manager package overlay.
- [desktop-base.nix](nixpaks/modules/desktop-base.nix): shared runtime and XDG storage.
- [portal-groups.nix](nixpaks/modules/portal-groups.nix),
  [desktop-integration.nix](nixpaks/modules/desktop-integration.nix): portal and desktop service
  grants.
- [browser-permissions.nix](nixpaks/modules/browser-permissions.nix),
  [chromium-browser.nix](nixpaks/modules/chromium-browser.nix): browser scopes and launcher.
- [nixpaks/wechat.nix](nixpaks/wechat.nix): WeChat package and data setup.
- [kernel-hardening.nix](kernel-hardening.nix), [apparmor/](apparmor/): kernel sysctl and AppArmor
  profiles.

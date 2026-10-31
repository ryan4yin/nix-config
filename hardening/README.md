# Linux Hardening

Deployed and interactively validated on `ai` (2026-10-31). Policy and limits:
[SECURITY.md](../SECURITY.md).

## Shared boundaries

- Cleared environment; filtered session D-Bus; private `/dev/shm`; per-app `/tmp`. Chromium-family
  browsers share an app-specific `/tmp` so external URLs reuse one browser instance.
- Read-only `/nix/store`; GPU and display; fonts and themes; LAN and Internet.
- Portals for file chooser, URI opening, notifications, input methods and document exports.
- No whole host home, system D-Bus, SSH agent, USB/serial, raw camera or raw PipeWire socket.
- Host loopback only for Firefox/Chromium; all other apps use pasta-isolated loopback.

## App permissions

`Media` means audio playback, microphone, Camera and ScreenCast portals. Writable paths are listed
explicitly; other files use the document portal. Every app also has private writable state.

| App          | Network       | Writable paths                                                                        | Grants                                                                                |
| ------------ | ------------- | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| Firefox      | Host loopback | `~/.mozilla`, personal files, Trash, Firefox artwork                                  | Media, browserpass, MPRIS, idle                                                       |
| Chromium     | Host loopback | `~/.config/chromium`, personal files                                                  | Media, browserpass, MPRIS, idle, v12 Secret                                           |
| Chrome       | Isolated      | `~/.config/google-chrome`, Downloads                                                  | Media, browserpass, MPRIS, idle, v12 Secret                                           |
| Brave Origin | Isolated      | `~/.config/BraveSoftware/Brave-Origin`, Downloads                                     | v12 Secret                                                                            |
| Edge         | Isolated      | `~/.config/microsoft-edge`, Downloads                                                 | v12 Secret                                                                            |
| QQ           | Isolated      | Personal files, private app state                                                     | Media, notifications, tray, MPRIS, idle, accessibility                                |
| Telegram     | Isolated      | Personal files, private app state                                                     | Media, notifications, tray, MPRIS, idle, accessibility, Ayatana indicators            |
| Zoom         | Isolated      | `~/.zoom`, `zoomus.conf`, `zoom.conf`, Downloads, `Documents/Zoom`, private app state | Media, X11/XWayland, FHS, SNI tray, idle, `/dev/video0-1`, read-only `/sys/class/drm` |
| WeChat       | Isolated      | `Documents/WeChat_Data`, its HOME mapping and `xwechat_files` link, private app state | Media, X11/xcb, FHS, SNI tray                                                         |

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
- Brave/Edge renderer and permission checks pass, but headless page export still times out.

## Validation

- Passed: `just fmt`, `just test`, `ai-niri` build and `shoukei-niri` eval.
- Deployed on `ai`; interactive startup and tray checks passed for Chrome, Firefox, QQ, Telegram,
  Zoom and WeChat.
- Chromium/Chrome: renderer sandbox, mounts, rendering and disposable-profile persistence passed.
  Chromium reaches host loopback; Chrome cannot.
- Firefox: disposable headless screenshot passed.
- Brave/Edge: renderer and permission checks passed; headless page export timed out.
- Evidence: [browsers](tests/browser-runtime.md),
  [Firefox/QQ/Telegram](tests/unified-app-runtime.md), [Zoom](tests/zoom-runtime.md),
  [WeChat](tests/wechat-runtime.md).

## Code map

- [nixpaks/](nixpaks/): wrappers and Home Manager package overlay.
- [desktop-base.nix](nixpaks/modules/desktop-base.nix): shared runtime and XDG storage.
- [portal-groups.nix](nixpaks/modules/portal-groups.nix),
  [desktop-integration.nix](nixpaks/modules/desktop-integration.nix): portal and desktop service
  grants.
- [browser-permissions.nix](nixpaks/modules/browser-permissions.nix),
  [chromium-browser.nix](nixpaks/modules/chromium-browser.nix): browser scopes and launcher.
- [bwraps/wechat.nix](bwraps/wechat.nix): WeChat FHS and data setup.
- [kernel-hardening.nix](kernel-hardening.nix), [apparmor/](apparmor/): kernel sysctl and AppArmor
  profiles.

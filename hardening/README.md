# Linux Hardening

- **Status:** draft rollout; not activated. Permissions below describe configuration, not proven
  functionality.
- **Policy and limits:** [SECURITY.md](../SECURITY.md).
- **Cookie crypto:** Chromium-family browsers use the app-scoped Secret portal and write `v12`
  cookies. No browser gets broad GNOME Keyring access. Existing `v11` cookies require re-login.

## Shared boundaries

- Clear inherited environment; filter session D-Bus; private shared memory.
- Allow GPU/display, fonts/themes, read-only `/nix/store`, and LAN/Internet access.
- Allow file chooser, URI opening, notifications and input-method portals.
- Allow exported document-portal files; existing exports may remain accessible without another
  prompt.
- Deny whole host home, system D-Bus, SSH agent, USB/serial, raw cameras (except Zoom's two V4L2
  nodes) and the raw PipeWire socket.
- Only Firefox/Chromium share host loopback. All other apps use pasta isolate.
- `/tmp` is private per app; Chromium-family browsers share an app-specific `/tmp` across launches
  so external URLs reuse the existing browser instance instead of reopening the same profile.
- Only Firefox/Chromium/Chrome get browserpass: password store, GnuPG configuration/home and agent
  access. Chromium-family browsers alone get the app-scoped Secret portal; no app gets broad Secret
  Service access.

## App permissions

**Media** means audio playback + microphone, Camera and ScreenCast portals. **Personal files** means
Documents, Downloads, Music, Videos and Pictures. All apps also have their own writable state; exact
mounts live in [nixpaks/](nixpaks/).

- **Firefox** — Host loopback; media; browserpass. Writable `~/.mozilla`, personal files, Trash and
  Firefox media artwork. Wayland.
- **Chromium** — Same shared permissions as Firefox; profile `~/.config/chromium`. No
  Firefox-specific mounts. **v12 Secret portal**. Wayland.
- **Chrome** — Isolated loopback; media; browserpass. Writable `~/.config/google-chrome` and
  Downloads; other files via portal. **v12 Secret portal**. Wayland.
- **Brave Origin** — Isolated loopback; **no media or browserpass**. Writable
  `~/.config/BraveSoftware/Brave-Origin` and Downloads. **v12 Secret portal**. Wayland.
- **Edge** — Same restricted permissions as Brave; profile `~/.config/microsoft-edge`. **v12 Secret
  portal**. Wayland.
- **QQ** — Isolated loopback; media; personal files and private app state. No browserpass/keyring.
  Wayland.
- **Telegram** — Same file/network/media scopes as QQ; also permits Canonical/Ayatana indicator and
  desktop-feedback services. Wayland.
- **Zoom** — Isolated loopback; media. Writable `~/.zoom`, existing `zoomus.conf`/`zoom.conf`,
  Downloads, `Documents/Zoom` and private app state. No browserpass/keyring. FHS + X11/XWayland.
- **WeChat** — Isolated loopback; media. Writable `Documents/WeChat_Data`, preserving its HOME
  mapping and `xwechat_files` link. Other files via portal; no whole-Documents/Downloads mount or
  browserpass/keyring. FHS + X11/xcb.

Desktop integration:

- All browsers: read-only NSS certificates, printing, native notifications and accessibility.
- Firefox/Chromium/Chrome: MPRIS media controls and idle inhibition.
- Brave/Edge: no audio socket, Camera/ScreenCast methods, camera feature, MPRIS or idle inhibition.
  GPU rendering remains available; software video decoding is not prohibited.
- QQ/Telegram: native notifications, tray, MPRIS, accessibility and idle inhibition.
- WeChat/Zoom: portal notifications plus StatusNotifier tray integration; no MPRIS/accessibility.
- Zoom also gets idle inhibition, read-only `/sys/class/drm`, and the two host V4L2 camera nodes;
  its 7.2.1 client still captures the webcam directly instead of using the Camera portal.

## Browser data and secrets

**Decision**

| Item                    | Choice                                    |
| ----------------------- | ----------------------------------------- |
| Chromium-family secrets | Force `v12` via app-scoped Secret portal  |
| Broad GNOME Keyring     | No                                        |
| Old `v11` sessions      | Accept one-time re-login                  |
| Firefox                 | NSS + Primary Password; no Chromium `v12` |

**Why v12**

- App-scoped secret: only this browser's portal secret, not the whole keyring.
- Stronger primitives: HKDF-SHA256 + AES-256-GCM vs `v11` PBKDF2 + AES-128-CBC.
- Simple: one feature flag + one portal method, no custom keyring proxy.
- Current default: `v11` when GNOME Keyring/KWallet is available; `v10` otherwise.
- Chrome 130 added `v12`; Chrome 131+ can read it; write remains opt-in in Chrome 156.
- Verified: disposable Chrome and Chromium profiles wrote cookie prefix `v12` and initialized the
  portal successfully.

**How**

- Chrome, Chromium, Brave, Edge: `--enable-features=SecretPortalKeyProviderUseForEncryption`.
- Allow only `org.freedesktop.portal.Secret.RetrieveSecret`.
- Deny `org.freedesktop.secrets`; wrappers do not pass `--password-store=basic`.
- Keep the app ID stable (`com.google.Chrome`, etc.); the portal secret is app-scoped.

**Cost and limits**

- `v11` and `v12` cannot decrypt each other: old cookies and saved passwords may need to be
  recreated.
- Portal unavailable can fall back to weak `v10`; monitor
  `Local State.os_crypt.portal.prev_init_success`.
- Profile is not fully encrypted: bookmarks, history, localStorage, IndexedDB and extension data are
  readable by the browser. Sandbox blocks other apps, not browser compromise.

**Firefox**

- Saved logins: `logins.json` + `key4.db` (NSS).
- Cookies: `cookies.sqlite`; not Chrome-style OS encryption.
- Best practical setup: set a **Primary Password**, keep the profile `0700`, rely on LUKS + nixpak.
- Primary Password protects saved logins, not cookies. No `v12` equivalent.
- Firefox has no Secret portal or keyring grant; NSS is its cookie/password store.
- browserpass/GPG is separate: it exposes the password store and GPG-agent socket, not cookie
  encryption.

## Implementation decisions

- **One policy framework:** shared desktop runtime, opt-in portal/desktop services, shared browser
  permissions. No legacy branch.
- **Chromium sandbox stays enabled:** user-namespace isolation remains active inside nixpak; tests
  assert the renderer runs with `Seccomp=2` / `NoNewPrivs=1`.
- **Cookie encryption:** all Chromium-family browsers enable the app-scoped Secret portal and force
  new values to `v12`; old `v11` values require re-login.
- **Camera:** Chromium/Chrome explicitly enable `WebRtcPipeWireCamera`; camera and screen-sharing
  streams use portal-provided FDs.
- **Zoom/WeChat:** retain FHS runtime inside nixpak. The inner layer can only see outer-layer
  resources. Explicitly retain `/.flatpak-info` for portals.
- **WeChat data:** retain existing layout; reject unexpected links/directories. Use a synthetic
  app-specific machine ID; existing-account identity continuity is untested.

## Limits and merge gates

- **Brave/Edge:** headless page export still times out; full render/persistence/loopback checks are
  incomplete.
- **Interactive checks:** login persistence, browserpass, file chooser, IME, GPU video, camera,
  microphone and meeting screen sharing remain pending where not recorded below.
- **X11:** Zoom/WeChat have shared-display trust; portal permissions cannot enforce portal-only
  capture.
- **Audio/credentials:** PulseAudio grants recording authority; read-only GPG sockets still permit
  agent operations.
- **Network:** pasta isolates loopback, not LAN access. Desktop sharing means meeting capture;
  Chromecast discovery is unverified.

## Validation

- Passed: `just fmt`, `just test` (including policy regression checks), `ai-niri` build,
  `shoukei-niri` eval.
- Chrome/Chromium: renderer sandbox, environment, mounts, rendering and disposable-profile
  persistence passed. Chromium reaches host loopback; Chrome cannot.
- Brave/Edge: renderer and permission checks passed; page rendering timed out.
- Firefox: disposable headless screenshot passed. QQ: partial startup. Telegram: build only.
- Zoom/WeChat: disposable windows and nested isolation passed; full media/login workflows remain
  pending.
- Reproduction and evidence: [browsers](tests/browser-runtime.md),
  [Firefox/QQ/Telegram](tests/unified-app-runtime.md), [Zoom](tests/zoom-runtime.md),
  [WeChat](tests/wechat-runtime.md).

## Code map

- [nixpaks/](nixpaks/): app wrappers and Home Manager package overlay.
- [desktop-base.nix](nixpaks/modules/desktop-base.nix): shared runtime and XDG storage.
- [portal-groups.nix](nixpaks/modules/portal-groups.nix),
  [desktop-integration.nix](nixpaks/modules/desktop-integration.nix): opt-in service grants.
- [browser-permissions.nix](nixpaks/modules/browser-permissions.nix): browser media, personal-file,
  browserpass and Secret-portal scopes.
- [chromium-browser.nix](nixpaks/modules/chromium-browser.nix): common Chromium-family launcher and
  desktop entry.
- [bwraps/wechat.nix](bwraps/wechat.nix): retained WeChat FHS/data setup.
- [kernel-hardening.nix](kernel-hardening.nix): sysctl and unused-module restrictions.
- [apparmor/](apparmor/): profiles under development; FHS paths often need adaptation for Nix store
  binaries.

## References

- [Bubblewrap](https://github.com/containers/bubblewrap),
  [nixpak](https://github.com/nixpak/nixpak),
  [systemd hardening](https://wiki.nixos.org/wiki/Systemd/Hardening).
- [AppArmor profiles](https://github.com/roddhjav/apparmor.d),
  [NixOS AppArmor roadmap](https://discourse.nixos.org/t/apparmor-on-nixos-roadmap/57217).
- [NixOS workstation hardening](https://dataswamp.org/~solene/2022-01-13-nixos-hardened.html),
  [Linux insecurities](https://madaidans-insecurities.github.io/linux.html),
  [nix-mineral](https://github.com/cynicsketch/nix-mineral).

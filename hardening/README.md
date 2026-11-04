# Linux Hardening

Deployed and interactively validated on the Linux desktop host (2026-10-31). Policy and limits:
[SECURITY.md](../docs/SECURITY.md).

## Why these apps are sandboxed

The packaging scope is driven by blast radius and input exposure, not by treating the applications
as malicious. These apps parse complex local or remote content, load third-party plugins (OBS), or
hold powerful network/session privileges (Remmina); a parser, plugin or session compromise would
otherwise inherit the user's home, session D-Bus, devices and network. Each wrapper grants only the
ports, devices, sockets, writable directories and desktop portals needed by that app's documented
workflow.

## Shared boundaries

- Cleared environment; filtered session D-Bus; private `/dev/shm`; per-app `/tmp`. Chromium-family
  browsers share an app-specific `/tmp` so external URLs reuse one browser instance.
- Read-only `/nix/store`; GPU and display; fonts and themes; LAN and Internet.
- Portals for file chooser, URI opening, notifications, input methods and document exports.
- No whole host home, system D-Bus, SSH agent, raw USB/serial or raw camera. For
  Firefox/Chromium/Chrome, the only device passthrough is the FIDO HID interface of a security key:
  host udev rules hard-link FIDO-tagged hidraw nodes into `/dev/fido-hidraw`, which the sandbox
  binds together with read-only `/sys/class/hidraw` and the udev database, so keys can be plugged in
  after launch. Other HID interfaces, CCID and raw USB stay hidden. Raw PipeWire is granted only to
  MuseScore for its ALSA-via-PipeWire audio path; see [Limits](#limits).
- Host loopback only for Firefox/Chromium; all other apps use pasta-isolated loopback. Chromium is
  an intentional development exception. Brave Origin and Edge are backup browsers and receive no
  media grants.

## App permissions

`Media` means audio playback, microphone, Camera and ScreenCast portals. Writable paths are listed
explicitly; other files use the document portal. Every app also has private writable state.

| App          | Network       | Writable paths                                                                        | Grants                                                                                         |
| ------------ | ------------- | ------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| Firefox      | Host loopback | `~/.mozilla`, personal files, Trash, Firefox artwork                                  | Audio, browserpass, MPRIS, idle, FIDO2 key; camera/screen sharing intentionally unavailable    |
| Chromium     | Host loopback | `~/.config/chromium`, personal files                                                  | Media, browserpass, MPRIS, idle, FIDO2 key, v12 Secret                                         |
| Chrome       | Isolated      | `~/.config/google-chrome`, Downloads                                                  | Media, browserpass, MPRIS, idle, FIDO2 key, v12 Secret                                         |
| Brave Origin | Isolated      | `~/.config/BraveSoftware/Brave-Origin`, Downloads                                     | v12 Secret                                                                                     |
| Edge         | Isolated      | `~/.config/microsoft-edge`, Downloads                                                 | v12 Secret                                                                                     |
| QQ           | Isolated      | Personal files, private app state                                                     | Media, notifications, tray, MPRIS, idle, accessibility                                         |
| Telegram     | Isolated      | Personal files, private app state                                                     | Media, notifications, tray, MPRIS, idle, accessibility, Ayatana indicators                     |
| Zoom         | Isolated      | `~/.zoom`, `zoomus.conf`, `zoom.conf`, Downloads, `Documents/Zoom`, private app state | Media, X11/XWayland, FHS, SNI tray, idle, `/dev/video0-1`, read-only `/sys/class/drm`          |
| WeChat       | Isolated      | Documents, Downloads, app-scoped `wechat` data, private app state                     | Media, Wayland, X11 fallback, SNI tray, file chooser portal                                    |
| Foliate      | None          | Documents/Downloads/Pictures read-only, app-scoped state                              | File chooser, OpenURI, notifications, IME, accessibility                                       |
| Krita        | None          | Documents/Downloads/Pictures writable, app-scoped state                               | File chooser, OpenURI, print, inhibit, notifications, IME, accessibility                       |
| Bambu Studio | Isolated      | Documents/Downloads/Pictures writable, app-scoped state                               | X11/XWayland, PulseAudio, cloud/LAN network, file chooser, notifications, IME, accessibility   |
| OrcaSlicer   | Isolated      | Documents/Downloads/Pictures writable, app-scoped state                               | X11/XWayland, cloud/LAN network, file chooser, notifications, IME, accessibility               |
| Remmina      | Isolated      | `~/.config/remmina`, `~/.local/share/remmina`, `~/.remmina`, Downloads                | PulseAudio, SSH agent, file chooser, OpenURI, notifications, IME, accessibility                |
| OBS Studio   | Isolated      | `~/.config/obs-studio`, Videos/Pictures/Downloads                                     | ScreenCast, V4L2 camera (`/dev/video0-1`), PulseAudio, tray, notifications, IME, accessibility |
| Blender      | Isolated      | `~/.config/blender`, Documents/Downloads/Pictures/Videos                              | X11/XWayland, PulseAudio, notifications, IME, accessibility                                    |
| MuseScore    | Isolated      | `~/.config/MuseScore`, `~/.local/share/MuseScore`, Documents/Downloads/Music/Pictures | ALSA via PipeWire, ALSA sequencer, X11/XWayland, print, notifications, IME, accessibility      |
| mpv          | Isolated      | `~/.config/mpv`, `~/.cache/mpv`, `~/.local/state/mpv`; media dirs read-only           | MPRIS, file chooser, OpenURI                                                                   |
| imv          | None          | `$HOME` read-only                                                                     | File chooser, OpenURI                                                                          |

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
  are backup browsers, not media browsers. They also receive no FIDO2 passthrough.
- FIDO2 passthrough is limited to the hidraw interface whose report descriptor declares the FIDO
  usage page. On the CanoKey that is the FIDO interface only: its KBD and CCID interfaces, other HID
  devices and raw USB stay outside the sandbox. A compromised browser process can send raw CTAP to
  the key; the key's PIN and touch policy remain the authentication boundary. The read-only udev
  database exposes properties of all host devices, much of which is already readable via the sysfs
  device binds.
- CanoKey management (CanoKey Console over WebUSB) is intentionally unavailable: Firefox has no
  WebUSB and the sandbox exposes no raw USB. PCs only use the key; management happens in the phone
  app. See [canokey.nix](../modules/nixos/desktop/canokey.nix) for the policy and its limits.
- FIDO2 hotplug relies on udev events, which only reach the host network namespace. Firefox and
  Chromium therefore detect keys plugged in after launch; pasta-isolated Chrome needs the key
  present before launch. `/dev/fido-hidraw` is created at boot. When first deploying with `switch`
  instead of a reboot, run `sudo systemd-tmpfiles --create --prefix=/dev/fido-hidraw`, then replug
  the key (or `sudo udevadm trigger --action=add -s hidraw`) and fully restart the browsers: a
  browser started while the directory was missing has no bind for it.
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
- MuseScore receives the raw PipeWire socket so its ALSA driver can use the host `pcm.!default`
  PipeWire plugin. PipeWire is a general media graph, so this is broader than a single audio stream:
  a compromised MuseScore could enumerate other user-visible PipeWire media nodes. The alternative,
  direct `/dev/snd`, confines the media graph but bypasses PipeWire device selection, per-app volume
  and mixing.
- OBS on Linux defaults its recording path to `$HOME`. The sandbox intentionally binds only the
  declared home subdirectories, so recording output must target `Videos`, `Pictures` or `Downloads`;
  a file written to the home root exists only in the sandbox's transient mount namespace.

## Validation

- Passed: `just fmt`, `just test`, `ai-niri` build, `shoukei-niri` eval and all wrapper builds.
- Interactive validation passed for Firefox, Chrome, Chromium, Brave Origin, Edge, QQ, Telegram,
  Zoom, Bambu Studio and OrcaSlicer. Chromium's host-loopback/personal-file exception and the
  Brave/Edge no-media policy are intentional.
- OBS Studio passed interactive validation for PipeWire screen capture, V4L2 camera capture,
  desktop/microphone audio, local NVENC H.264 MP4 recording and local RTMP streaming. External
  provider authentication and browser sources remain unvalidated.
- Remmina, Blender, mpv and imv build and pass the policy suite; interactive validation is still
  pending. MuseScore passed launch, XWayland and ALSA-to-PipeWire routing checks; audible playback
  and user workflows still need confirmation.
- Chromium smoke test passed: renderer sandbox, environment clearing, bind scope, disposable-profile
  persistence and loopback policy.
- FIDO2 browser passthrough is enabled for Firefox/Chromium/Chrome only. WebAuthn with the CanoKey
  passed in Firefox and Chrome; Chromium and plugging the key in after launch still need validation.
- WeChat uses the native nixpkgs-master package with nixpak as the only bwrap layer. Build/policy
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
  [fido-bwrap.nix](nixpaks/modules/fido-bwrap.nix),
  [chromium-browser.nix](nixpaks/modules/chromium-browser.nix): browser scopes, FIDO2 passthrough
  wrapper and launcher.
- [nixpaks/wechat.nix](nixpaks/wechat.nix): WeChat package and data setup.
- [kernel-hardening.nix](kernel-hardening.nix), [apparmor/](apparmor/): kernel sysctl and AppArmor
  profiles.

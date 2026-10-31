# WeChat nested runtime verification

WeChat 4.1.13.26 built and opened a `Weixin` X11 window with a disposable profile. The final
candidate was `/nix/store/6wr94i7da0674k9hzs23fk2nr1ih4i3f-nixpak-wechat-4.1.13.26`. The existing
AppImage extraction, FHS runtime, X11 and fcitx settings remain in `hardening/bwraps/wechat.nix`;
the new nixpak wrapper adds an outer boundary.

The live extracted WeChat binary had three PID namespace identifiers, `NoNewPrivs: 1`, `Seccomp: 0`,
a network namespace different from the host, and `/.flatpak-info` identifying `com.tencent.WeChat`.
Its device view contained standard synthetic devices, `dri`, and the four explicit NVIDIA nodes; no
raw camera, USB or block devices. This smoke test does not establish an internal renderer sandbox
guarantee.

A sentinel in the disposable `Documents/WeChat_Data/home` was readable at WeChat's remapped HOME.
Its `xwechat_files` link retained the absolute target `Documents/WeChat_Data/xwechat_files`, which
remains bound inside both layers. The final launcher also rejected a separate disposable layout
containing a real `home/xwechat_files` directory, exited 1, and preserved its sentinel and contents.
It will not silently migrate an unexpected existing layout.

## Compatibility changes

As with Zoom, the wrapper preserves the outer `/.flatpak-info` file explicitly: the FHS automatic
root mount loop only propagates directories. The inner `--dev-bind /dev /dev` inherits the outer
filtered devices. The original inner network setting inherits pasta's isolated outer namespace,
including its private loopback.

The original inner `/home` reset hides the shared desktop base's XDG mounts. WeChat therefore
exposes its existing backing tree to the outer sandbox and keeps the original FHS HOME mapping. It
supplies `XDG_DOCUMENTS_DIR` and a coreutils-only PATH for the pre-FHS mkdir/link commands.
Xauthority is rebound after the inner HOME reset when present.

The first run aborted in libdbus because no machine ID was available. The WeChat policy supplies a
synthetic app-specific ID rather than the host ID. Login/device identity continuity with an existing
account remains untested. No credentials or real profile were used for this test.

## Historical constraint

Commit `0c7e43a2` removed `nixpaks/wechat-uos.nix`. Its previous TODO said the FHS runtime was
problematic inside another sandbox, but supplied no failure log. That old module also disabled X11
and set `QT_QPA_PLATFORM=kcb`, despite its xcb-only comment. Commit `28dee277` subsequently changed
the AppImage wrapper from Wayland to xcb and added fcitx environment settings. These records do not
prove the original failure's cause. Current runtime testing establishes that retaining FHS inside
nixpak is feasible with the explicit compatibility changes above.

## Repeat safely

Use the same disposable-home command as [Zoom](zoom-runtime.md), with WeChat's output and
executable, and additionally set `XDG_DOCUMENTS_DIR="$wechat_probe_dir/Documents"`. Prepare
`Documents/WeChat_Data/home` and `Documents/WeChat_Data/xwechat_files` beneath that disposable home
before launching. The smoke test stops before QR login and uses no account. Inspect the exact test
PID through `/proc` while the timeout is active; verify that its window and processes disappear
after timeout.

Pending manual checks: existing account persistence, QR/login, fcitx input, notifications/tray,
portal file chooser and selected-file access, downloads, voice/video calls, camera/screencast portal
support and clipboard workflows. Camera and ScreenCast methods are explicit grants; raw capture
devices and the host PipeWire socket are not exposed. X11 retains its display trust limitations, so
portal permission does not imply all capture requires portal consent.

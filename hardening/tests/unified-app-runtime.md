# Unified desktop-policy validation

Validation on the Linux `ai` host, using the pinned nixpkgs and nixpak inputs. These checks use
disposable profiles and do not read existing browser or chat accounts.

| Check                             | Result  | Scope                                                                                                                                                                                                                                              |
| --------------------------------- | ------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Firefox, QQ, Telegram derivations | Pass    | All three wrappers evaluated and built after conversion to the shared desktop policy.                                                                                                                                                              |
| Browser policy regression checks  | Pass    | `policy.nix` returned `true`; covers Firefox/Chromium capability and portal-call parity, host loopback, Chrome isolated networking and media grants, browserpass scope, and forbidden service/device access.                                       |
| Firefox headless screenshot       | Pass    | Exit status 0; `about:blank` produced a PNG with a fresh profile and HOME under `/var/tmp`.                                                                                                                                                        |
| QQ startup                        | Partial | With a disposable HOME and `--ozone-platform=headless`, initialized private QQ data and stayed running for 12 seconds until explicitly terminated. Headless EGL/GPU initialization errors occurred. No account login or media function was tested. |
| Telegram runtime                  | Not run | Evaluation and build only.                                                                                                                                                                                                                         |

The Firefox invocation used the built wrapper with
`--headless --no-remote --profile "$HOME/.mozilla/test" --screenshot "$HOME/Downloads/smoke.png" about:blank`.
The disposable environment retained only the launcher's PATH, USER, locale, Wayland display and
session-bus/runtime-directory variables, with HOME and all XDG storage paths redirected to the
temporary tree. Existing account profiles were not mounted. The temporary tree was removed after the
process exited.

Use `/var/tmp`, not `/tmp`, for disposable host profiles. Nixpak emits the sandbox's private `/tmp`
mount after filesystem binds; a profile prepared under host `/tmp` is hidden by that mount. An
application that creates a fresh profile inside the resulting tmpfs can appear to work without
testing persistence.

The common policy replaces the earlier direct camera-device and PipeWire-socket grants with explicit
Camera and ScreenCast portal methods. QQ and Telegram retain their private XDG data and existing
personal-file mappings, and opt into notifications, tray, MPRIS and accessibility. Firefox retains
its `.mozilla` profile and MPRIS artwork mounts and shares browser capability definitions with
Chromium.

Interactive validation remains necessary for camera capture, microphone input, video playback,
desktop/window sharing, file chooser/save operations, IME, tray, notifications and media controls.
The QQ headless startup is not evidence that those functions work. Browser encrypted-login migration
is a separate gate; see `browser-runtime.md` for the Chromium-family validation and limitations.

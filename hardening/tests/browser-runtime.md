# Browser runtime verification

- Run from the repository root as the Linux desktop user, with user D-Bus; no sudo or activation.
- Tests use disposable profiles only, synthetic environment canaries, and no environment dumps.
- **Keep HOME under `/var/tmp`:** the sandbox's private `/tmp` masks a HOME created there. Rendering
  reads a host-prepared HTML file through the profile bind; persistence requires a nonempty
  `Local State` file in the disposable host HOME.

## Reproduce

Build against the locked flake inputs:

```bash
mkdir -p browser-validation
for app in chromium google-chrome brave-origin microsoft-edge; do
  APP="$app" nix build --impure --out-link "browser-validation/$app" --expr '
    let
      flake = builtins.getFlake (toString ./.);
      pkgs = import flake.inputs.nixpkgs {
        system = builtins.currentSystem;
        config.allowUnfree = true;
      };
    in pkgs.callPackage
      (./hardening/nixpaks + "/${builtins.getEnv "APP"}.nix")
      {
        mkNixPak = flake.inputs.nixpak.lib.nixpak {
          inherit pkgs;
          inherit (pkgs) lib;
        };
      }
  '
done
```

Run each test separately so a failing browser does not hide the other results:

```bash
python3 hardening/tests/verify-chromium.py browser-validation/chromium/bin/chromium
python3 hardening/tests/verify-chromium.py browser-validation/google-chrome/bin/google-chrome
python3 hardening/tests/verify-chromium.py browser-validation/brave-origin/bin/brave-origin
python3 hardening/tests/verify-chromium.py browser-validation/microsoft-edge/bin/microsoft-edge
```

- Each launch has a 35-second limit; failures exit nonzero. Temporary HOME is cleaned up.
- Intermediate JSON records process checks; final JSON appears only after all checks pass.

## Current measured results

Host: `ai`, x86_64 Linux. All four rebuilt after the shared policy/media opt-in changes and tested
with `/var/tmp` HOME, explicit Fontconfig configuration, CJK fonts, and narrow NVIDIA mappings.

| Browser                | Process/security checks | HTML rendering  | Profile persistence | Host loopback | Overall  |
| ---------------------- | ----------------------- | --------------- | ------------------- | ------------- | -------- |
| Chromium 156.0.8078.73 | Pass                    | Pass            | Pass                | Pass: allowed | **Pass** |
| Chrome 156.0.8078.73   | Pass                    | Pass            | Pass                | Pass: blocked | **Pass** |
| Brave Origin 1.98.60   | Pass                    | **35s timeout** | Not reached         | Not reached   | **Fail** |
| Edge 156.0.4314.42     | Pass                    | **35s timeout** | Not reached         | Not reached   | **Fail** |

Measured evidence:

- All four build and have live renderers with `Seccomp=2`, `NoNewPrivs=1`; no sandbox-disabling
  flags are present.
- Actual bwrap arguments pass user/PID namespace, effective network flag, clear environment, new
  session, parent-death, and private `/dev/shm` checks. No broad HOME/`/home`/`/dev`, SSH,
  system-bus, raw video, X11, GVfs, or direct PipeWire binds. Brave/Edge also have no browserpass
  credential or PulseAudio binds.
- All nine canaries are absent: `NIXPAK_VALIDATION_CANARY`, `SSH_AUTH_SOCK`, `GPG_AGENT_INFO`, and
  upper/lowercase `HTTP_PROXY`, `HTTPS_PROXY`, `ALL_PROXY`.
- Chromium/Chrome render the prepared file without Fontconfig errors and persist `Local State`. Host
  HTTP control succeeds; Chromium fetches its marker. Chrome reports `ERR_CONNECTION_REFUSED`,
  returns no marker, and sends zero requests to the host listener.
- Brave/Edge stall on `--headless=new --dump-dom` despite `--timeout=10000`. Cause unresolved;
  system D-Bus/UPower warnings also occur in passing browsers. No upstream-package control was run,
  so this does not establish a wrapper regression.

## Current permission checks

- **Firefox/Chromium/Chrome:** evaluated media opt-in enables PulseAudio, camera/screencast portals,
  MPRIS, and inhibition. **Brave/Edge:** all disabled; live socket-bind checks pass.
- Chromium/Chrome main processes enable `WaylandWindowDecorations,WebRtcPipeWireCamera`. Brave/Edge
  retain Wayland decorations and have **no camera feature**; all flag checks pass.
- Firefox/Chromium share host networking and allow personal files; Chrome/Brave/Edge use pasta
  isolation without personal-file access. Firefox parity is evaluated, not runtime-tested here.
- GPU nodes remain available for webpage rendering. Interactive audio/camera/capture, hardware
  acceleration, CJK/IME, portals, downloads, and browserpass remain unverified by this headless
  test.
- Inventory: [hardening README](../README.md). Security limits: [SECURITY.md](../../SECURITY.md).

## Cookie crypto and v11 migration

- Chromium-family wrappers enable `SecretPortalKeyProviderUseForEncryption` and receive only
  `org.freedesktop.portal.Secret.RetrieveSecret`; they do **not** get
  `--talk=org.freedesktop.secrets`.
- A disposable-profile probe under `/var/tmp` served an HTTP `Set-Cookie`, then inspected the
  profile DB: the cookie prefix was `v12` (`763132`) and
  `Local State.os_crypt.portal.prev_init_success` was true.
- Existing `v11` cookies cannot be decrypted by the v12 provider; v11/v12 use different KDFs and
  cipher modes. Expect a one-time re-login after switching profiles to v12.
- If the portal is unavailable, Chromium can fall back to v10. That is weak; monitor portal startup
  and do not treat this as fail-closed encryption.
- Firefox uses NSS (`key4.db`/`logins.json`) and `cookies.sqlite`, not Chrome OSCrypt. Set a Firefox
  Primary Password if saved-login at-rest protection matters.
- Sources:
  [feature defaults](https://github.com/chromium/chromium/blob/156.0.8078.73/chrome/browser/browser_features.cc),
  [v11 provider](https://github.com/chromium/chromium/blob/156.0.8078.73/components/os_crypt/async/browser/freedesktop_secret_key_provider.cc),
  [v12 provider](https://github.com/chromium/chromium/blob/156.0.8078.73/components/os_crypt/async/browser/secret_portal_key_provider.cc),
  [prefix decryption](https://github.com/chromium/chromium/blob/156.0.8078.73/components/os_crypt/async/common/encryptor.cc).

## Check these files

```bash
ruff format --check hardening/tests/verify-chromium.py
ruff check hardening/tests/verify-chromium.py
prettier --check hardening/tests/browser-runtime.md
git diff --check
```

## Manual Chrome media smoke test

Use the official WebRTC samples. They require no account and do not upload the stream; the preview
stays local. Chrome uses pasta-isolated loopback, so a test server on the host is intentionally not
reachable.

- Camera + microphone: <https://webrtc.github.io/samples/src/content/getusermedia/gum/>
  - Click **Start**, accept Chrome and portal prompts, verify local video preview and audio level.
- Screen sharing: <https://webrtc.github.io/samples/src/content/getusermedia/getdisplaymedia/>
  - Click **Start**, choose a window/screen, verify preview, then **Stop**.
- Files: use any site's upload control, then download the same file; confirm the file chooser and
  Downloads work.

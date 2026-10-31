#!/usr/bin/env python3
"""Runtime smoke test: verify a built nixpak Chromium without existing profiles.

Usage: python3 hardening/tests/verify-chromium.py /nix/store/.../bin/chromium
Requires Linux procfs and an active user D-Bus session. Uses only stdlib.
"""

import argparse
import http.server
import json
import os
import signal
import subprocess
import tempfile
import threading
import time
import urllib.request
from pathlib import Path


def processes():
    result = {}
    for path in Path("/proc").glob("[0-9]*"):
        try:
            status = dict(
                line.split(":", 1)
                for line in (path / "status").read_text().splitlines()
                if ":" in line
            )
            args = (path / "cmdline").read_bytes().split(b"\0")
            result[int(path.name)] = (int(status["PPid"]), status, args)
        except (OSError, ValueError):
            pass
    return result


def descendants(root, table):
    found = {root}
    while True:
        more = {pid for pid, (parent, _, _) in table.items() if parent in found}
        if more <= found:
            return found
        found |= more


def run_browser(command, env):
    try:
        return subprocess.run(
            command, check=False, env=env, capture_output=True, timeout=35
        )
    except subprocess.TimeoutExpired as error:
        detail = (error.stderr or b"").decode(errors="replace")[-6000:]
        raise AssertionError(
            "Disposable headless command timed out:\n" + detail
        ) from None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("browser", type=Path)
    args = parser.parse_args()
    browser = str(args.browser.absolute())
    profile = {
        "chromium": "chromium",
        "google-chrome": "google-chrome",
        "microsoft-edge": "microsoft-edge",
        "brave-origin": "BraveSoftware/Brave-Origin",
    }[args.browser.name]
    media = args.browser.name in {"chromium", "google-chrome"}
    report = {}
    with tempfile.TemporaryDirectory(
        prefix="nixpak-chromium-test-", dir="/var/tmp"
    ) as tmp:
        home = Path(tmp)
        for directory in [
            f".config/{profile}",
            "Downloads",
            ".cache",
            ".local/share",
            ".local/state",
        ]:
            (home / directory).mkdir(parents=True, exist_ok=True)
        (home / ".config/user-dirs.dirs").write_text(
            'XDG_DOWNLOAD_DIR="$HOME/Downloads"\n'
        )
        env = {
            key: os.environ[key]
            for key in [
                "PATH",
                "USER",
                "XDG_RUNTIME_DIR",
                "DBUS_SESSION_BUS_ADDRESS",
                "WAYLAND_DISPLAY",
                "LANG",
            ]
            if key in os.environ
        }
        canaries = [
            "NIXPAK_VALIDATION_CANARY",
            "SSH_AUTH_SOCK",
            "GPG_AGENT_INFO",
            "HTTP_PROXY",
            "HTTPS_PROXY",
            "ALL_PROXY",
            "http_proxy",
            "https_proxy",
            "all_proxy",
        ]
        env.update({name: "disposable-test-value" for name in canaries})
        env.update(
            HOME=tmp,
            XDG_CONFIG_HOME=f"{tmp}/.config",
            XDG_CACHE_HOME=f"{tmp}/.cache",
            XDG_DATA_HOME=f"{tmp}/.local/share",
            XDG_STATE_HOME=f"{tmp}/.local/state",
            NIXPAK_VALIDATION_CANARY="disposable-test-value",
        )
        base = [
            browser,
            "--headless=new",
            "--disable-gpu",
            "--no-first-run",
            "--no-default-browser-check",
            "--disable-background-networking",
            f"--user-data-dir={tmp}/.config/{profile}/validation-profile",
        ]
        with (home / "browser.log").open("w+") as log:
            proc = subprocess.Popen(
                base + ["--remote-debugging-port=0", "about:blank"],
                env=env,
                stdout=log,
                stderr=log,
                start_new_session=True,
            )
            try:
                deadline = time.monotonic() + 35
                renderers = []
                while time.monotonic() < deadline:
                    table = processes()
                    owned = descendants(proc.pid, table)
                    renderers = [
                        pid
                        for pid in owned
                        if pid in table
                        and b"--type=renderer" in b" ".join(table[pid][2]).split()
                    ]
                    if renderers or proc.poll() is not None:
                        break
                    time.sleep(0.2)
                if not renderers:
                    log.seek(0)
                    # This log belongs only to the disposable browser, never a host environment dump.
                    raise AssertionError(
                        "No live renderer; disposable browser log:\n"
                        + log.read()[-6000:]
                    )
                report["renderers"] = [
                    {
                        "pid": pid,
                        "Seccomp": table[pid][1]["Seccomp"].strip(),
                        "NoNewPrivs": table[pid][1]["NoNewPrivs"].strip(),
                    }
                    for pid in renderers
                ]
                assert all(
                    row["Seccomp"] == "2" and row["NoNewPrivs"] == "1"
                    for row in report["renderers"]
                ), report
                bwrap = [
                    row[2]
                    for pid, row in table.items()
                    if pid in owned and Path(os.fsdecode(row[2][0])).name == "bwrap"
                ]
                required = [
                    b"--unshare-user-try",
                    b"--unshare-pid",
                    b"--unshare-net",
                    b"--clearenv",
                    b"--new-session",
                    b"--die-with-parent",
                ]
                assert any(
                    all(flag in command for flag in required) for command in bwrap
                ), "Missing bwrap isolation arguments"
                report["bwrap_required_flags"] = [
                    os.fsdecode(flag) for flag in required
                ]
                browser_pids = set()
                for renderer in renderers:
                    pid = table[renderer][0]
                    while pid in owned and pid in table:
                        command = b" ".join(table[pid][2]).split()
                        if (
                            any(arg.startswith(b"--user-data-dir=") for arg in command)
                            and not any(arg.startswith(b"--type=") for arg in command)
                            and b"--clearenv" not in command
                        ):
                            browser_pids.add(pid)
                            break
                        pid = table[pid][0]
                checked = 0
                for pid in browser_pids:
                    command = b" ".join(table[pid][2]).split()
                    assert b"--no-sandbox" not in command, "Chromium sandbox disabled"
                    features = [
                        arg.split(b"=", 1)[1].split(b",")
                        for arg in command
                        if arg.startswith(b"--enable-features=")
                    ]
                    assert features and b"WaylandWindowDecorations" in features[-1], (
                        "Missing Wayland feature flag"
                    )
                    assert (b"WebRtcPipeWireCamera" in features[-1]) == media, (
                        "Camera feature does not match browser media policy"
                    )

                assert all(
                    b"--no-sandbox" not in b" ".join(table[pid][2]).split()
                    for pid in renderers
                ), "Renderer sandbox disabled"
                report["camera_and_wayland_features"] = {
                    "WaylandWindowDecorations": True,
                    "WebRtcPipeWireCamera": media,
                }
                report["chromium_sandbox_flags"] = (
                    "--no-sandbox absent; renderer Seccomp=2/NoNewPrivs=1"
                )
                for pid in browser_pids:
                    try:
                        entries = Path(f"/proc/{pid}/environ").read_bytes().split(b"\0")
                    except PermissionError:
                        continue
                    assert not any(
                        entry.startswith(name.encode() + b"=")
                        for entry in entries
                        for name in canaries
                    ), "Canary leaked into browser"
                    checked += 1
                assert checked, "Could not inspect browser environment"
                report["browser_environments_without_canary"] = checked
                report["absent_canary_variables"] = canaries
                command = next(command for command in bwrap if b"--clearenv" in command)
                network_flags = [
                    arg
                    for arg in command[: command.index(b"--")]
                    if arg in {b"--unshare-net", b"--share-net"}
                ]
                expected_network = (
                    b"--share-net"
                    if args.browser.name == "chromium"
                    else b"--unshare-net"
                )
                assert network_flags[-1] == expected_network, (
                    "Unexpected effective network namespace policy"
                )
                report["effective_network_namespace_flag"] = os.fsdecode(
                    expected_network
                )

                for forbidden in [b"/dev/video0", b"/tmp/.X11-unix"]:
                    assert forbidden not in command, "Unexpected device/socket bind"
                assert not any(
                    b"/pipewire-0" in arg or b"/gvfsd" in arg for arg in command
                ), "Unexpected direct desktop socket bind"
                assert any(
                    command[i : i + 2] == [b"--tmpfs", b"/dev/shm"]
                    for i in range(len(command) - 1)
                ), "Missing private shared memory"
                report["private_shm_and_no_direct_pipewire_gvfs_camera_x11"] = True
                # Inspect bind operands, not synthetic --dev /dev or tmpfs mounts.
                bind_options = {
                    b"--bind",
                    b"--bind-try",
                    b"--ro-bind",
                    b"--ro-bind-try",
                    b"--dev-bind",
                    b"--dev-bind-try",
                }
                options = command[: command.index(b"--")]
                binds = [
                    (options[i + 1], options[i + 2])
                    for i, option in enumerate(options)
                    if option in bind_options
                ]
                broad_paths = {
                    b"/",
                    b"/home",
                    b"/dev",
                    os.fsencode(tmp),
                    os.fsencode(os.environ["HOME"]),
                }
                for source, destination in binds:
                    for path in (source, destination):
                        assert path.rstrip(b"/") not in broad_paths and path != b"/", (
                            "Broad host filesystem bind"
                        )
                        parts = path.split(b"/")
                        if not media:
                            assert b"pulse" not in parts and not any(
                                part.startswith(b"pipewire-") for part in parts
                            ), (
                                "Media-disabled browser has an audio/PipeWire socket bind"
                            )

                        assert b".ssh" not in parts, "SSH directory bind"
                        assert not (
                            path == b"/run/dbus" or path.startswith(b"/run/dbus/")
                        ), "System D-Bus bind"
                        assert not (
                            path.startswith((b"/dev/video", b"/tmp/.X11-unix"))
                        ), "Raw camera or X11 bind"
                        if args.browser.name in {"brave-origin", "microsoft-edge"}:
                            assert not (
                                {b".gnupg", b"gnupg", b"password-store"} & set(parts)
                            ), "Unexpected browserpass credentials bind"
                report["no_broad_home_dev_ssh_or_system_bus_bind"] = True
                report["media_socket_policy"] = (
                    "PulseAudio allowed; direct PipeWire absent"
                    if media
                    else "PulseAudio and PipeWire binds absent"
                )

                report["browserpass_bind_scope"] = (
                    "allowed only for Chromium/Chrome; absent for Brave/Edge"
                )

            finally:
                if proc.poll() is None:
                    proc.terminate()
                    try:
                        proc.wait(timeout=10)
                    except subprocess.TimeoutExpired:
                        os.killpg(proc.pid, signal.SIGKILL)
                        proc.wait()

        print(json.dumps(report, indent=2), flush=True)
        render_file = home / ".config" / profile / "render-canary.html"
        render_file.write_text("<html><body>NIXPAK_RENDER_OK</body></html>")
        positive = run_browser(
            base
            + [
                "--timeout=10000",
                "--dump-dom",
                render_file.as_uri(),
            ],
            env,
        )
        assert positive.returncode == 0 and b"NIXPAK_RENDER_OK" in positive.stdout, (
            "Disposable page failed to render"
        )
        assert b"Fontconfig error" not in positive.stderr, (
            "Fontconfig could not load sandbox configuration"
        )
        report["headless_page_render"] = (
            "host-prepared file rendered; no Fontconfig errors"
        )
        state_file = home / ".config" / profile / "validation-profile" / "Local State"
        assert state_file.is_file() and state_file.stat().st_size > 0, (
            "Browser profile state did not persist to disposable host HOME"
        )
        report["disposable_profile_persistence"] = (
            "nonempty Local State exists in host HOME"
        )

        class Handler(http.server.BaseHTTPRequestHandler):
            hits = 0

            def do_GET(self):
                type(self).hits += 1
                self.send_response(200)
                self.end_headers()
                self.wfile.write(
                    b"<html><body>NIXPAK_HOST_LOOPBACK_CANARY</body></html>"
                )

            def log_message(self, *args):
                pass

        with http.server.ThreadingHTTPServer(("127.0.0.1", 0), Handler) as server:
            thread = threading.Thread(target=server.serve_forever, daemon=True)
            thread.start()
            url = f"http://127.0.0.1:{server.server_port}/"
            assert (
                b"NIXPAK_HOST_LOOPBACK_CANARY"
                in urllib.request.urlopen(url, timeout=5).read()
            )
            Handler.hits = 0
            try:
                result = run_browser(base + ["--timeout=10000", "--dump-dom", url], env)
                assert result.returncode == 0, "Loopback browser command failed"
                if args.browser.name == "chromium":
                    assert (
                        b"NIXPAK_HOST_LOOPBACK_CANARY" in result.stdout
                        and Handler.hits > 0
                    ), "Chromium must reach host loopback"
                    report["host_loopback"] = (
                        "allowed: host and Chromium fetched the listener marker"
                    )
                else:
                    assert b"ERR_CONNECTION_REFUSED" in result.stdout + result.stderr, (
                        "Expected explicit browser connection refusal"
                    )
                    assert (
                        b"NIXPAK_HOST_LOOPBACK_CANARY" not in result.stdout
                        and Handler.hits == 0
                    ), "Browser reached host loopback"
                    report["host_loopback"] = (
                        "blocked: host positive control succeeded; browser ERR_CONNECTION_REFUSED; zero server requests"
                    )
            finally:
                server.shutdown()
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()

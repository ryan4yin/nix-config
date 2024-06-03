"""
  Set proxy for nix-daemon to speed up downloads
  You can safely ignore this file if you don't need a proxy.
                                                                                                                                                                                                                                                                                          
  https://github.com/NixOS/nix/issues/1472#issuecomment-1532955973
"""

import os
import plistlib
import shlex
import subprocess
from pathlib import Path


NIX_DAEMON_PLIST = Path("/Library/LaunchDaemons/org.nixos.nix-daemon.plist")
NIX_DAEMON_NAME = "org.nixos.nix-daemon"
# http proxy provided by my homelab's bypass router
HTTP_PROXY = "http://192.168.5.179:7890"

PLIST = plistlib.loads(NIX_DAEMON_PLIST.read_bytes())


def update_plist():
    os.chmod(NIX_DAEMON_PLIST, 0o644)
    NIX_DAEMON_PLIST.write_bytes(plistlib.dumps(PLIST))
    os.chmod(NIX_DAEMON_PLIST, 0o444)


def reload_daemon():
    # reload the plist
    for cmd in (
        f"launchctl unload {NIX_DAEMON_PLIST}",
        f"launchctl load {NIX_DAEMON_PLIST}",
    ):
        print(cmd)
        subprocess.run(shlex.split(cmd), capture_output=False)


def set_proxy():
    # set http/https proxy
    # NOTE: curl only accept the lowercase of `http_proxy`!
    # NOTE: https://curl.se/libcurl/c/libcurl-env.html
    PLIST["EnvironmentVariables"]["http_proxy"] = HTTP_PROXY
    PLIST["EnvironmentVariables"]["https_proxy"] = HTTP_PROXY
    update_plist()
    reload_daemon()


def unset_proxy():
    # remove http proxy
    PLIST["EnvironmentVariables"].pop("http_proxy", None)
    PLIST["EnvironmentVariables"].pop("https_proxy", None)
    update_plist()
    reload_daemon()


if __name__ == "__main__":
    # set_proxy()
    unset_proxy()

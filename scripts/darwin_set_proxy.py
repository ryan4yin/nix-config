"""
  set proxy for nix-daemon to speed up downloads
  https://github.com/NixOS/nix/issues/1472#issuecomment-1532955973
"""
import os
import plistlib
import shlex
import subprocess
from pathlib import Path


NIX_DAEMON_PLIST = Path("/Library/LaunchDaemons/org.nixos.nix-daemon.plist")
NIX_DAEMON_NAME = "org.nixos.nix-daemon"
# http proxy provided by clash
HTTP_PROXY = "http://127.0.0.1:7890"       

pl = plistlib.loads(NIX_DAEMON_PLIST.read_bytes())

# set http proxy
# pl["EnvironmentVariables"]["HTTP_PROXY"] = HTTP_PROXY
# pl["EnvironmentVariables"]["HTTPS_PROXY"] = HTTP_PROXY

# remove http proxy
pl["EnvironmentVariables"].pop("HTTP_PROXY", None)
pl["EnvironmentVariables"].pop("HTTPS_PROXY", None)

os.chmod(NIX_DAEMON_PLIST, 0o644)
NIX_DAEMON_PLIST.write_bytes(plistlib.dumps(pl))
os.chmod(NIX_DAEMON_PLIST, 0o444)

# reload the plist
for cmd in (
	f"launchctl unload {NIX_DAEMON_PLIST}",
	f"launchctl load {NIX_DAEMON_PLIST}",
):
    print(cmd)
    subprocess.run(shlex.split(cmd), capture_output=False)


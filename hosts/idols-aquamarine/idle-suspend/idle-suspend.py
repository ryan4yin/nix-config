#!/usr/bin/env python3
"""Suspend aquamarine only when the host is genuinely idle and WoL is armed."""

from __future__ import annotations

import json
import os
import subprocess
import sys
import time
from pathlib import Path

STATE = Path("/run/aquamarine-idle-suspend")
IDLE_MINUTES = int(os.environ.get("AQUAMARINE_IDLE_MINUTES", "60"))
IDLE_SECONDS = IDLE_MINUTES * 60
ASR_PORT = os.environ.get("AQUAMARINE_ASR_PORT", "18080")
GPU_BUSY_LIMIT = 5
LOAD_LIMIT = 0.75


def log(message: str) -> None:
    print(message, flush=True)


def run(*args: str) -> subprocess.CompletedProcess[str] | None:
    try:
        return subprocess.run(
            args,
            check=False,
            capture_output=True,
            text=True,
            timeout=10,
        )
    except (FileNotFoundError, subprocess.SubprocessError, OSError) as exc:
        log(f"command failed: {' '.join(args)}: {exc}")
        return None


def set_state(now: int) -> None:
    STATE.write_text(f"{now}\n", encoding="utf-8")


def get_state(now: int) -> int:
    try:
        value = int(STATE.read_text(encoding="utf-8").strip())
        return value if value <= now else now
    except (FileNotFoundError, OSError, ValueError):
        set_state(now)
        return now


def deep_s3_selected() -> bool:
    try:
        return "[deep]" in Path("/sys/power/mem_sleep").read_text(encoding="utf-8")
    except OSError as exc:
        log(f"cannot read /sys/power/mem_sleep: {exc}")
        return False


def wol_armed() -> bool:
    interfaces = list(Path("/sys/class/net").glob("en*"))
    if not interfaces:
        log("no wired interface found")
        return False

    for interface in interfaces:
        result = run("ethtool", interface.name)
        if result is None or result.returncode != 0:
            continue
        if "Wake-on: g" in result.stdout:
            return True

    log("Wake-on-LAN is not armed")
    return False


def active_user_session() -> bool:
    result = run("loginctl", "list-sessions", "--no-legend", "--json=short")
    if result is None or result.returncode != 0:
        log("cannot inspect logind sessions")
        return True

    try:
        sessions = json.loads(result.stdout or "[]")
    except json.JSONDecodeError as exc:
        log(f"cannot parse logind sessions: {exc}")
        return True

    for session in sessions:
        if session.get("class") == "user":
            log(f"active user session: {session.get('session')}")
            return True
    return False


def blocked_sleep_inhibitor() -> bool:
    result = run("systemd-inhibit", "--list", "--no-legend", "--what=sleep")
    if result is None or result.returncode != 0:
        log("cannot inspect sleep inhibitors")
        return True

    for line in result.stdout.splitlines():
        if line.rstrip().endswith(" block"):
            log(f"blocking sleep inhibitor: {line.strip()}")
            return True
    return False


def active_asr_request() -> bool:
    result = run(
        "ss",
        "-Htn",
        "state",
        "established",
        f"( sport = :{ASR_PORT} )",
    )
    if result is None or result.returncode != 0:
        log("cannot inspect ASR connections")
        return True
    if result.stdout.strip():
        log("active ASR connection")
        return True
    return False


def gpu_busy() -> bool:
    paths = list(Path("/sys/class/drm").glob("card*/device/gpu_busy_percent"))
    for path in paths:
        try:
            value = int(path.read_text(encoding="utf-8").strip())
        except (OSError, ValueError) as exc:
            log(f"cannot read {path}: {exc}")
            return True
        if value > GPU_BUSY_LIMIT:
            log(f"{path} is {value}% busy")
            return True
    return False


def high_load() -> bool:
    load = os.getloadavg()[0]
    if load > LOAD_LIMIT:
        log(f"1-minute load is {load:.2f}")
        return True
    return False


def main() -> int:
    now = int(time.time())

    if not deep_s3_selected():
        log("deep S3 is not selected; not suspending")
        return 0

    if not wol_armed():
        set_state(now)
        return 0

    if (
        active_user_session()
        or blocked_sleep_inhibitor()
        or active_asr_request()
        or gpu_busy()
        or high_load()
    ):
        set_state(now)
        return 0

    last = get_state(now)
    if now - last < IDLE_SECONDS:
        remaining = IDLE_SECONDS - (now - last)
        log(f"idle for {now - last}s; {remaining}s remaining")
        return 0

    STATE.unlink(missing_ok=True)
    log(f"idle for {now - last}s; suspending")
    result = run("systemctl", "suspend")
    if result is None or result.returncode != 0:
        log("systemctl suspend failed")
        set_state(int(time.time()))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())

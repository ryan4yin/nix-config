#!/usr/bin/env python3
"""Track media and joystick activity for hypridle without creating inhibitors."""

import argparse
import json
import logging
import math
import os
from pathlib import Path
import selectors
import signal
import subprocess
import sys
import tempfile
import time

LOG = logging.getLogger("hypridle-activity")
_FAILURES = {}


def report_failure(key, message):
    if _FAILURES.get(key) != message:
        LOG.warning("%s", message)
        _FAILURES[key] = message


def recovered(key):
    if _FAILURES.pop(key, None) is not None:
        LOG.info("%s recovered", key)


POLL_INTERVAL = 5.0  # Device discovery and heartbeat; input events remain immediate.
MEDIA_INTERVAL = 15.0
HEARTBEAT_TTL = 30.0
COMMAND_TIMEOUT = 2.0
AUDIO_THRESHOLD = 0.0001  # -80 dBFS: ignore digital silence and tiny background noise.
PEAK_BUDGET = 1.0
# Linux input-event-codes.h; keep check and tests independent of evdev/pyudev.
EV_KEY, EV_ABS = 1, 3
STICKS = {0, 1, 3, 4}  # ABS_X/Y/RX/RY
TRIGGERS = {2, 5, 9, 10}  # ABS_Z/RZ/GAS/BRAKE
HATS = set(range(16, 24))


def state_path():
    runtime = os.environ.get("XDG_RUNTIME_DIR")
    if not runtime or not os.path.isabs(runtime):
        raise ValueError("XDG_RUNTIME_DIR must be an absolute directory")
    return Path(runtime) / "hypridle-activity" / "state.json"


def timestamp(value):
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        return False
    try:
        return math.isfinite(value) and value >= 0
    except OverflowError:
        return False


def blocked(state, timeout, now):
    """Fail open for absent, stale, or invalid monitor state."""
    if not isinstance(state, dict):
        return False
    heartbeat = state.get("heartbeat")
    activity = state.get("last_activity")
    if not timestamp(heartbeat) or heartbeat > now:
        return False
    if now - heartbeat >= HEARTBEAT_TTL:
        return False
    if activity is None:
        return False
    if not timestamp(activity) or activity > heartbeat:
        return False
    return now - activity < timeout


def check(path, timeout, now=None):
    try:
        with path.open() as stream:
            state = json.load(stream)
    except (OSError, ValueError) as error:
        LOG.warning("Cannot read activity state: %s", error)
        return 0
    return int(blocked(state, timeout, time.monotonic() if now is None else now))


def write_state(path, last_activity, heartbeat):
    path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w", dir=path.parent, prefix=".state-", delete=False
        ) as stream:
            temporary = stream.name
            json.dump({"last_activity": last_activity, "heartbeat": heartbeat}, stream)
            stream.write("\n")
        os.replace(temporary, path)
    finally:
        if temporary is not None:
            try:
                os.unlink(temporary)
            except FileNotFoundError:
                pass


def publish(path, activity, heartbeat):
    try:
        write_state(path, activity, heartbeat)
        recovered("state")
    except OSError as error:
        report_failure("state", f"Cannot publish activity state: {error}")


def audio_active(peak):
    return timestamp(peak) and peak > AUDIO_THRESHOLD


def output_peak(pulse):
    """Sample output monitors only; a running sink can still contain silence."""
    sinks = [
        sink for sink in pulse.sink_list()
        if sink.state == "running" and not sink.mute
        and isinstance(sink.monitor_source, int)
        and 0 <= sink.monitor_source < 0xFFFFFFFF
    ]
    if not sinks:
        return 0.0
    # Rotate the starting output so a large device list cannot starve later sinks.
    now = time.monotonic()
    start = int(now / MEDIA_INTERVAL) % len(sinks)
    sinks = sinks[start:] + sinks[:start]
    deadline = now + PEAK_BUDGET
    peak = 0.0
    for sink in sinks:
        remaining = deadline - time.monotonic()
        if remaining < 0.1:
            break
        value = pulse.get_peak_sample(sink.monitor_source, min(0.25, remaining))
        if timestamp(value):
            peak = max(peak, value)
        if audio_active(peak):
            break
    return peak


def probe_peak():
    # Isolated by the caller's subprocess timeout, including connection/list calls.
    import pulsectl

    with pulsectl.Pulse("hypridle-activity", connect=False) as pulse:
        pulse.connect(timeout=0.5)
        return output_peak(pulse)


def playing(output):
    return any(line.strip() == "Playing" for line in output.splitlines())


def media_active():
    active = False
    try:
        result = subprocess.run(
            [sys.executable, __file__, "audio-peak"],
            capture_output=True, text=True, timeout=COMMAND_TIMEOUT, check=True,
        )
        active = audio_active(json.loads(result.stdout))
        recovered("audio")
    except (OSError, subprocess.SubprocessError, ValueError) as error:
        report_failure("audio", f"Audio probe failed: {error}")
    try:
        result = subprocess.run(
            ["playerctl", "-a", "status"],
            capture_output=True, text=True, timeout=COMMAND_TIMEOUT, check=False,
        )
        # playerctl exits 1 when there are no players, an ordinary idle state.
        if result.returncode in (0, 1):
            recovered("players")
            if result.returncode == 0:
                active = active or playing(result.stdout)
        else:
            report_failure("players", f"Media player probe exited with {result.returncode}")
    except (OSError, subprocess.SubprocessError) as error:
        report_failure("players", f"Media player probe failed: {error}")
    return active


def gamepad_active(event, absinfo):
    """Ignore synchronization, release, sensor, and centered-stick events."""
    if event.type == EV_KEY:
        return event.value in (1, 2)
    if event.type != EV_ABS:
        return False
    if event.code in HATS:
        return event.value != 0
    if event.code not in STICKS | TRIGGERS:
        return False
    info = absinfo(event.code)
    if info is None or info.max <= info.min:
        return False
    span = info.max - info.min
    if event.code in STICKS:
        center = (info.min + info.max) / 2
        deadzone = max(info.flat, span * 0.15)
        return abs(event.value - center) > deadzone
    return event.value > info.min + max(info.flat, span * 0.05)


class Joysticks:
    def __init__(self, context, device_factory, selector):
        self.context = context
        self.device_factory = device_factory
        self.selector = selector
        self.devices = {}

    def remove(self, path):
        device = self.devices.pop(path)
        self.selector.unregister(device.fd)
        device.close()

    def reconcile(self):
        # Periodic enumeration also retries permissions and disconnected devices.
        try:
            paths = {
                dev.device_node
                for dev in self.context.list_devices(subsystem="input")
                if dev.get("ID_INPUT_JOYSTICK") == "1"
                and dev.device_node
                and Path(dev.device_node).name.startswith("event")
            }
            recovered("discovery")
        except Exception as error:
            report_failure("discovery", f"Joystick discovery failed: {error}")
            return
        for path in set(self.devices) - paths:
            self.remove(path)
        for path in paths - self.devices.keys():
            device = None
            try:
                device = self.device_factory(path)
                # No grab(): Steam and games must continue receiving events.
                self.selector.register(device.fd, selectors.EVENT_READ, path)
                self.devices[path] = device
                recovered(path)
                LOG.info("Monitoring joystick %s", path)
            except (OSError, ValueError) as error:
                if device is not None:
                    device.close()
                report_failure(path, f"Cannot monitor joystick {path}: {error}")

    def read(self, path):
        device = self.devices.get(path)
        if device is None:
            return False
        active = False
        try:
            # evdev.read() drains one bounded batch; the selector reports more.
            for event in device.read():
                active = gamepad_active(event, device.absinfo) or active
        except BlockingIOError:
            pass
        except OSError as error:
            LOG.info("Joystick unavailable %s: %s", path, error)
            self.remove(path)
        return active

    def close(self):
        for path in list(self.devices):
            self.remove(path)


def daemon(path):
    # The check command must work without hardware libraries or device access.
    import evdev
    import pyudev

    stopping = False

    def stop(_signum, _frame):
        nonlocal stopping
        stopping = True

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    last_activity = None
    last_event_publish = None
    next_poll = 0.0
    next_media = 0.0
    with selectors.DefaultSelector() as selector:
        joysticks = Joysticks(pyudev.Context(), evdev.InputDevice, selector)
        try:
            while not stopping:
                now = time.monotonic()
                if now >= next_poll:
                    next_poll = now + POLL_INTERVAL
                    joysticks.reconcile()
                    if now >= next_media:
                        next_media = now + MEDIA_INTERVAL
                        if media_active():
                            last_activity = time.monotonic()
                    now = time.monotonic()
                    publish(path, last_activity, now)
                for key, _ in selector.select(max(0, next_poll - time.monotonic())):
                    if joysticks.read(key.data):
                        last_activity = time.monotonic()
                        if last_event_publish is None or last_activity - last_event_publish >= 1:
                            publish(path, last_activity, last_activity)
                            last_event_publish = last_activity
        finally:
            joysticks.close()


def positive_seconds(value):
    number = float(value)
    if not math.isfinite(number) or number <= 0:
        raise argparse.ArgumentTypeError("timeout must be finite and positive")
    return number


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("daemon")
    commands.add_parser("audio-peak", help="print output peak amplitude without saving audio")
    check_parser = commands.add_parser("check")
    check_parser.add_argument("--timeout", type=positive_seconds, required=True)
    args = parser.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(name)s: %(levelname)s: %(message)s")
    if args.command == "audio-peak":
        print(json.dumps(probe_peak()))
        return 0
    try:
        path = state_path()
    except ValueError as error:
        LOG.error("%s", error)
        return 0 if args.command == "check" else 2
    if args.command == "check":
        return check(path, args.timeout)
    daemon(path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

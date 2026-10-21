# Idle activity protection

Hypridle handles keyboard/pointer idle time, monitor power and locking. Its screen-off and lock
listeners ignore application inhibitors because some applications keep them after playback stops.
The `hypridle-activity` user service supplies an additional condition based on observed gamepad and
media activity. It follows the same session target as hypridle and requires a Home Manager/system
activation; editing these source files does not change the running desktop.

## Activity and timing

- Gamepads are identified by udev's `ID_INPUT_JOYSTICK` property and read through evdev without
  grabbing the device. Discovery retries every five seconds, including after hotplug or permission
  changes. Centered analog-stick noise, synchronization and release events do not count as activity.
- Media is sampled every five seconds using PulseAudio's sink-input API (including PipeWire Pulse)
  and MPRIS. An uncorked client playback stream or an MPRIS player reporting `Playing` counts as
  activity. Native PipeWire-only playback without MPRIS is not covered. This is stream-state
  detection, not a measurement of audible sound: muted or silent active streams can keep the screen
  awake. Recording alone does not count.
- Screen-off and locking each require their configured timeout since the last observed activity, in
  addition to hypridle's keyboard/pointer timeout. Pausing playback or putting down the controller
  therefore leaves an idle grace period. Sampling and hypridle's 30-second condition retry make
  these approximate deadlines.

The monitor writes atomic state under `$XDG_RUNTIME_DIR/hypridle-activity/` using monotonic time.
Missing, malformed, future-dated or 30-second-old heartbeat data does **not** block idle actions.
This prevents a crashed monitor from disabling automatic locking indefinitely; detection failure can
consequently allow screen-off during use. Starting the monitor does not manufacture activity. The
monitor prevents automatic idle actions; it does not unlock the session or power on an already
blanked display when a controller is pressed.

## Verification

Run the focused tests without hardware or third-party Python libraries:

```console
python3 -m unittest discover -s home/linux/gui/base/hypridle -p 'test_*.py' -v
```

After activating the configuration, inspect the service and its state:

```console
systemctl --user status hypridle-activity.service
journalctl --user -u hypridle-activity.service -n 50 --no-pager
hypridle-activity check --timeout 1200
```

The check exits **1** while activity blocks the requested timeout, and **0** when allowed. Use the
host's screen-off or lock timeout as appropriate. Test a connected but untouched controller, actual
controller input with the game muted, playback without keyboard input, and then no input/playback.
Confirm that the state timestamp stops advancing in the last case. Keep normal keyboard access
available for waking the display.

If logs report permission denied for a controller, inspect its session/udev access rules. The
service does not run as root and does not grant broad access to keyboard or mouse devices. An
unchanging held control produces no new input events, and unusual controller layouts or drift
outside the deadzone require hardware verification.

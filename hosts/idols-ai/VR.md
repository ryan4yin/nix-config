# Quest 3 PC VR on idols-ai

WiVRn streams PC VR games to Quest 3. It supplies the OpenXR runtime; xrizer translates OpenVR
games. This host uses the server and command-line tools without the Dashboard. SteamVR does not need
to run, but compatibility still depends on the game and translation layer.

## First activation and persistence

Run `just niri` on idols-ai from this branch's worktree, or after merging it. Log out and back in so
Steam sees `PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1`. That variable is what makes pressure-vessel
mount WiVRn's `$XDG_RUNTIME_DIR/wivrn/comp_ipc` socket into a game's container; without it the
game's OpenXR client fails with `ERROR_RUNTIME_UNAVAILABLE` and the headset stays black.

The root filesystem is a 4 GiB tmpfs. These directories are preserved with mode 0700:

- `~/.config/wivrn/`: server settings, paired headset public keys and discovery cookie.
- `~/.android/`: ADB host keys, so USB authorization survives a reboot.

Before the first activation, migrate any existing directories to their matching locations under
`/persistent/home/<user>/`. Stop WiVRn first. If both locations contain data, reconcile them before
activating; do not overwrite existing pairing state or ADB keys. Do not display or upload ADB
private keys, or copy them into this repository.

OpenXR/OpenVR runtime pointers and sockets remain temporary. WiVRn switches runtime pointers while a
headset is connected and restores previous configuration when it disconnects. Do not manage these
pointers as read-only Home Manager files, persist IPC sockets, or delete existing runtime
configurations blindly.

## Wireless connection and pairing

1. Connect the PC by Ethernet and Quest 3 to the trusted home LAN (`192.168.5.0/24`). Prefer 5 GHz
   or 6 GHz Wi-Fi near the access point. Guest Wi-Fi or client isolation can block discovery and
   streaming.
2. Install the WiVRn 26.9 client on the headset: the Meta Store build is packaged as
   `org.meumeu.wivrn`, the GitHub release APK as `org.meumeu.wivrn.github`. Client and server
   versions must match; check the installed server with `wivrn-server --version` after updates.
3. The server does not start automatically at login or boot. From this repository on idols-ai, start
   it when you want to use VR:

   ```console
   just vr
   just vr-status
   ```

   `just vr` returns immediately and leaves `wivrn-audio.service` waiting up to ten minutes for the
   headset. When it connects, that unit makes WiVRn's speaker and microphone the defaults and moves
   any stream that is already playing. `just vr-audio` does the same switch in the foreground when
   the headset is already connected, and `just vr-stop` cancels the wait and restores the saved
   devices. Starting the service does not enable it for future logins.

4. Allow a new headset to pair for two minutes:

   ```console
   wivrnctl pair --duration 2
   ```

   This prints a PIN. Open WiVRn on the headset, connect to `ai`, and enter the PIN. If discovery
   fails, enter `192.168.5.100` manually. Reconnection after pairing does not require running this
   command again.

5. Audio follows the headset: WiVRn's `wivrn.sink` and `wivrn.source` exist only while a headset is
   connected, so the switch happens then, not at `just vr` time. Check the current defaults with
   `pactl get-default-sink` and `pactl get-default-source`.

Manage paired headsets with `wivrnctl list-paired`, `wivrnctl rename`, or `wivrnctl unpair`. Consult
`wivrnctl --help` and the subcommand's `--help` for arguments.

## Service, settings and logs

Manage the server through systemd so starts retain NVIDIA offload and the CAP_SYS_NICE wrapper:

```console
systemctl --user restart wivrn
just vr-stop
just vr-status
journalctl --user -u wivrn -b -n 100 --no-pager
just vr-logs
```

Service logs use the host's existing persistent journal. There is no separate Dashboard log folder
or log exporter. For server settings, edit `~/.config/wivrn/config.json` following the WiVRn 26.9
configuration schema, then restart the service. The NixOS module also supports declarative server
configuration; an enabled declarative config takes precedence over the user file. Headset-side
settings remain available in the headset application.

## Launch games on the RTX 4090

Set this in each VR game's Steam Properties -> Launch Options:

```text
__NV_PRIME_RENDER_OFFLOAD=1 __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only %command%
```

These are the variables the system's `nvidia-offload` wrapper sets, written out because Steam runs
inside a bubblewrap sandbox that does not mount `/run`, so it cannot see
`/run/current-system/sw/bin/nvidia-offload`.

The game has to land on the same GPU as the server. A game left on the Intel iGPU makes the server's
swapchain allocation fail, which shows up as `vkAllocateMemory: VK_ERROR_OUT_OF_DEVICE_MEMORY` and
`xrt_comp_create_swapchain failed` in `journalctl --user -u wivrn`, followed by an xrizer panic that
kills the game. This applies when launching from the headset too: WiVRn starts applications in
separate systemd units, and an already running Steam client keeps its own environment, so neither
path inherits the server's GPU environment. For non-Steam applications, start them under
`nvidia-offload` from a normal shell. Select a Proton version according to the game's compatibility
reports; GE-Proton or DW-Proton alone does not guarantee VR compatibility.

## USB connection

Enable Quest developer mode, connect a data-capable USB cable, and accept the headset's USB
debugging authorization prompt. ADB is already installed in the desktop profile. The current systemd
handles USB access for the active local session. Developer mode is needed for USB or sideloading,
not for the Meta Store wireless workflow.

For sideloading, download the matching official APK and use `adb install -r <apk-path>`. The GitHub
release APK is packaged as `org.meumeu.wivrn.github`, the Meta Store build as `org.meumeu.wivrn`;
pass the package you actually installed.

Pair over Wi-Fi first. For an already paired headset with the GitHub APK installed:

```console
adb devices
adb reverse tcp:9757 tcp:9757
adb shell am start -a android.intent.action.VIEW -d "wivrn+tcp://127.0.0.1:9757" org.meumeu.wivrn.github
```

If multiple devices are connected, add `-s <serial>` to each ADB command. Disable headset Wi-Fi
while validating USB so the test cannot silently use wireless streaming. Recreate the reverse
mapping after disconnecting USB.

## Encoding and hardware validation

The package enables Vulkan Video encoding but does not enable NVENC. WiVRn 26.9 probes Vulkan
encoding before falling back to VAAPI or x264 when NVENC is absent. Check the journal's encoder
configuration after connecting: offload variables alone do not prove hardware encoding. Vulkan
encoding in this release supports H.264/H.265, not AV1. NVENC/AV1 requires a CUDA-enabled WiVRn
build.

- Pair, connect, launch a game, and check both compositor and game GPU usage:
  `nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv` has to list both
  `wivrn-server` and the game.
- Confirm the journal has no `vkAllocateMemory` or `xrt_comp_create_swapchain` failures, and that
  `~/.local/state/xrizer/xrizer.txt` has no `ERROR_RUNTIME_UNAVAILABLE`.
- Restart with systemd and verify the server remains owned by `wivrn.service`.
- Reboot the PC and reconnect without pairing again; verify saved settings and USB authorization
  remain intact.
- Test audio routing (`just vr` and `just vr-stop`), microphone, controllers, and a supported
  OpenXR/OpenVR game.

Configuration and package checks do not replace these headset tests.

# Fcitx5 Vinput

On `ai` and `shoukei`, install a Sherpa-ONNX model, then hold and release **right Alt** to dictate.
**Right Shift** toggles Chinese/English; **left Shift** remains a normal modifier. Open Vinput from
the application launcher for settings.

## One-time setup (CLI)

The GUI path is **Resources → Models** (download and activate), then **Control → ASR Providers**.
The equivalent non-interactive commands are:

```sh
vinput model add onnx-xasr-zh-en-960ms-punct-stream   # download (~130 MB, sha256-verified)
vinput model use onnx-xasr-zh-en-960ms-punct-stream   # set as active model
systemctl --user restart vinput-daemon
```

`vinput model list -a` lists the available registry models.

## Backends

- `shoukei` uses CPU. Leave the model's provider at its default.
- `ai` uses OpenVINO when the model's `vinput-model.json` sets `"provider": "openvino"`; restart
  `vinput-daemon` after changing it. One-shot enable:

  ```sh
  f=~/.local/share/vinput/models/sherpa-onnx/x-asr-960ms-streaming-zipformer-transducer-zh-en-punct-int8/vinput-model.json
  jq '.model.provider = "openvino"' "$f" | tee "$f.tmp" && mv "$f.tmp" "$f"
  systemctl --user restart vinput-daemon
  ```

  The user needs the `render` group and a new login after deployment.

## Persistence

Models are stored in `~/.local/share/vinput/models/sherpa-onnx/` and the core config lives in
`~/.config/vinput/config.json`. Both directories are bind-mounted from `/persistent` on the
tmpfs-root hosts (see `hosts/idols-ai/preservation.nix`); without that they are wiped on every
reboot and the daemon logs `Local ASR provider model is not configured`. Review model source and
license before installing.

**NPU execution status: unverified.** On `ai`, the OpenVINO runtime and NPU plugin load, the daemon
opens `/dev/accel/accel0`, and the bundled WAV sample transcribes. However, the NPU busy-time
counter did not increase, and no NPU profiling data has been collected. These observations do not
confirm that model computation ran on the NPU; CPU fallback or partial fallback remains possible.

## Diagnostics

```sh
journalctl --user -b -u vinput-daemon
```

Check the Sherpa/OpenVINO logs for the selected device. A definitive check needs NPU profiling
enabled for inference and non-zero per-layer NPU timings; a loaded plugin or device busy-time
counter alone is not conclusive.

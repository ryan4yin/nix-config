# Fcitx5 Vinput

On `ai` and `shoukei`, install a Sherpa-ONNX model in Vinput under **Resources → Models**, then
select it in **Control → ASR Providers**. Hold and release **right Alt** to dictate. **Right Shift**
toggles Chinese/English; **left Shift** remains a normal modifier. Open Vinput from the application
launcher for settings.

Models are stored in `~/.local/share/vinput/models/sherpa-onnx/`. Review their source and license
before installing.

## Backends

- `shoukei` uses CPU. Leave the model's provider at its default.
- `ai` uses OpenVINO when the model's `vinput-model.json` sets `"provider": "openvino"`; restart
  `vinput-daemon` after changing it. The user needs the `render` group and a new login after
  deployment.

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

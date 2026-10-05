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

## Persistence

Models are stored in `~/.local/share/vinput/models/sherpa-onnx/` and the core config lives in
`~/.config/vinput/config.json`. Both directories are bind-mounted from `/persistent` on the
tmpfs-root hosts (see `hosts/idols-ai/preservation.nix`); without that they are wiped on every
reboot and the daemon logs `Local ASR provider model is not configured`. Review model source and
license before installing.

## Diagnostics

```sh
journalctl --user -b -u vinput-daemon
```

Check the daemon logs for the selected provider, model load, and transcription errors.

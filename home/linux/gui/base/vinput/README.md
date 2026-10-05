# Fcitx5 Vinput

Voice input on `ai` and `shoukei`, backed by a Sherpa-ONNX model. Open Vinput from the application
launcher for settings.

## Key bindings

- Right Alt: record. Hold and release to dictate.
- Right Ctrl: open the command palette (`/model /asr /scene /proc`).

Vinput resolves `TriggerKey` > `CommandKeys` > `MenuKey`. `TriggerKey` is right Alt by default; the
config sets `MenuKey` to right Ctrl and clears `CommandKeys`, which otherwise defaults to right Ctrl
and would shadow `MenuKey`. The addon reads list options as `[Option]` plus `0=`, not the
`[Trigger]` shorthand in upstream's `vinput-config(5)` man page.

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

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

## API keys

Scene providers reference the DeepSeek key as `{{env.DEEPSEEK_API_KEY}}` (see `vinput scene list`),
and the daemon resolves that from its own environment. A systemd user service inherits neither the
interactive shell's environment nor any app's env file, so the unit reads
`EnvironmentFile=%h/.secrets/nushell-secrets.env`. A missing file fails the unit; a file without the
variable still starts, but every correction fails with
`vinput-daemon: environment variable in api_key (...) for provider 'deepseek' is unset or empty`.

```sh
systemctl --user show -p EnvironmentFiles vinput-daemon   # which file the unit reads
systemctl --user restart vinput-daemon                    # after the file changes
```

`~/.secrets` is bind-mounted from `/persistent` on the tmpfs-root host (see
`hosts/idols-ai/preservation.nix`), so the file survives a reboot once it exists there.

## Where the config lives

`~/.config/vinput/config.json` is an out-of-store symlink to [config.json](./config.json) in this
repository, so the edits vinput makes itself — the settings GUI, `vinput scene edit`,
`vinput config set` — land in the checkout and show up in `git status`. That works because the
daemon writes through a temporary file plus `rename` **after resolving symlinks**, so the link
survives the write; a write that ever did replace it leaves a real file, and `force` in the module
retakes the path on the next switch. Editing the file by hand needs `just niri`; editing it through
vinput does not.

Models are stored in `~/.local/share/vinput/models/sherpa-onnx/`, and that directory is bind-mounted
from `/persistent` on the tmpfs-root hosts (see `hosts/idols-ai/preservation.nix`); without it the
models are wiped on every reboot and the daemon logs `Local ASR provider model is not configured`.
Review model source and license before installing.

## Diagnostics

```sh
journalctl --user -b -u vinput-daemon
```

Check the daemon logs for the selected provider, model load, and transcription errors.

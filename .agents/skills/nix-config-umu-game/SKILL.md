---
name: nix-config-umu-game
description:
  Use when installing a Windows game launcher (二次元 / gacha or any non-Steam game) on a NixOS
  desktop via umu-launcher, given an installer URL or an .exe, or when such a launcher opens an
  invisible, transparent, black, or empty window under Wine.
---

# Installing a Windows game launcher with umu

The bundled `scripts/umu-install.nu` renders the files in `scripts/templates/`. It is generic: it
creates a prefix, runs the installer, and writes the launchers -- run it as-is; its
`PROTONPATH`/`GAMEID` handling is what makes this work. **Every per-game detail lives under
`~/Games/`**, never in this repo.

## Bundled files

| Path                            | What                                                |
| ------------------------------- | --------------------------------------------------- |
| `scripts/umu-install.nu`        | installer and template renderer                     |
| `scripts/templates/*.tpl`       | non-executable templates; placeholders use `@NAME@` |
| `scripts/tests/test_install.py` | offline regression tests                            |

## Layout

| Path                            | What                                                     |
| ------------------------------- | -------------------------------------------------------- |
| `~/Games/global.conf`           | optional, sourced by every game before its own `conf`    |
| `~/Games/<name>/prefix`         | the Wine prefix (`WINEPREFIX`)                           |
| `~/Games/<name>/conf`           | optional per-game overrides (`ENABLE_GAMESCOPE=1`, ...)  |
| `~/Games/<name>/prelaunch`      | optional executable, run before every launch             |
| `~/Games/<name>/run`            | generated launcher                                       |
| `~/Games/<name>/exec`           | generated helper: `exec <exe-or-tool> [args...]`         |
| `~/Games/<name>/<name>.desktop` | generated desktop entry                                  |
| `~/Games/<name>/uninstall`      | generated: drop the desktop entry and (with `y`) the dir |

Run, from the repo root:

`nu .agents/skills/nix-config-umu-game/scripts/umu-install.nu <name> <setup.exe> <launcher> [gameid] [setup-args...]`

`<launcher>` is relative to the prefix and `GAMEID` defaults to `umu-default`. `PROTONPATH` resolves
from `$PROTONPATH`, `$UMU_PROTONPATH` (exported by `modules/nixos/desktop/gaming.nix` from
`pkgs.dwproton-bin.steamcompattool`), the newest `dwproton` in `/nix/store`, then Steam's per-user
`compatibilitytools.d`; the generated scripts re-read it at launch, so a Nix update is picked up
without regenerating.

## Procedure

1. **Research first.** Mandatory before inventing any fix: a documented fix beats a custom patch
   every time. Check the game's Lutris installer YAML
   (`https://lutris.net/api/installers/<game-slug>`, which encodes `winetricks` verbs, `write_file`
   content, and `prelaunch_command`), then ProtonDB (`protondb.com/app/<id>`), the Steam Community /
   r/linux_gaming threads, and GitHub issues for the launcher and Proton.
2. **Slug.** Pick a lowercase `<name>` (e.g. `wuthering-waves`).
3. **GAMEID.** The umu database maps a title to a `GAMEID` whose protonfixes add CJK fonts, drop the
   `SteamOS`/`SteamDeck` vars, and keep Wine's `Documents` inside the prefix. **Without it some
   games save into the host home or the wrong prefix.** Fetch
   `https://raw.githubusercontent.com/Open-Wine-Components/umu-database/main/umu-database.csv`,
   match the title, and use its `umu-<id>`; if nothing matches, leave the default.
4. **Download.** `curl -fL <url> -o ~/Games/<name>/setup.exe`. The CN store pages are JS/token
   driven, so the user normally supplies the URL or the file itself.
5. **Install.** Run the bundled script. The first run also downloads umu's Steam runtime and the
   protonfix fonts, so it is slow. The installer is usually a GUI the user clicks through, but
   **extra args after `[gameid]` go to `setup.exe`**, so try a silent flag first (`/S`, `/quiet`,
   `--silent`); if it ignores them, fall back to clicking. On some CN installers the last page
   auto-starts the launcher. The script writes `run`/`exec` even if the installer exits non-zero, so
   a killed installer is not fatal.
6. **Find the launcher.** If `<launcher>` is only known after the install:
   `find ~/Games/<name>/prefix/drive_c -iname '*launcher*.exe'`, then re-run the bundled script
   (idempotent) or set `LAUNCHER` in `~/Games/<name>/conf`.
7. **Per-game fix.** Port step 1 findings into `~/Games/<name>/prelaunch` (bash, `chmod +x`):
   `winetricks` verbs via `~/Games/<name>/exec winetricks <verbs>`, file patches or registry tweaks
   via `~/Games/<name>/exec`. Never commit the fix to this repo.
8. **Re-run every launch, not once.** A launcher that self-updates overwrites files it patches, so
   those patches belong in `prelaunch`.
9. **Verify.** `~/Games/<name>/run` must open a visible launcher window and re-running `prelaunch`
   must be idempotent. The launcher may then download the game body itself (tens of GB) -- that is
   the launcher's job, not this skill's, so the install is **done** once the window is usable.
   `ENABLE_LOG=1` captures `last-run.log` when something misbehaves.

## Invisible / transparent launcher window

A WebView2/.NET (WPF) launcher that shows an empty or fully transparent window is rendering with
`AllowsTransparency`. Fix the DLL, not Wine:

1. `find ~/Games/<name>/prefix/drive_c -iname 'launcher_main.dll'` (usually under a `X.Y.Z.W`
   version dir).
2. Rename that WPF property in place, keeping the byte length so PE offsets stay valid:
   `bbe -e 's/\x12AllowsTransparency/\x09IsEnabled\x1bA\x00\x03AAAAA/' <dll>`.
3. Put it in `~/Games/<name>/prelaunch` so it is re-applied on every launch, because a launcher
   self-update restores the original DLL. Restart the launcher after patching.

## Half-width tile instead of fullscreen

Niri tiles a new window into a column of `default-column-width { proportion 0.500000; }` (50%), and
a launcher that only opens a large borderless window cannot take over the screen by itself: with a
4K panel at `scale 1.5` Niri's logical space is 2560x1440, so a window asking for the physical
3840x2160 becomes an ordinary half-width tile. Nothing is broken -- the umu app-id is just not
covered by a rule.

Every umu/Proton game reports `steam_app_<GAMEID>`. In this repo
`home/linux/gui/niri/conf/windowrules.kdl` matches `app-id="^steam_app_[0-9]+$"` and sets
`open-fullscreen true`, so games open fullscreen without a per-game rule. `niri validate` checks the
live config, `Mod+Shift+F` (`fullscreen-window`) toggles an already-open window, and setting the
in-game resolution to the compositor's logical size (2560x1440 here) avoids the mismatch too.

## Mojibake that is not a missing font

Latin-looking garbage such as `æˆ‘å·²é˜…è¯»` where the launcher should say 我已阅读并同意, while
other Chinese on the same screen renders fine, is UTF-8 decoded as Windows-1252. The app's string is
intact (for this launcher it is correct UTF-16 in `KRSDKEx.dll`) and the fonts are fine; the prefix
is simply reporting a Western locale. Confirm the pattern:

```bash
python3 -c "print('我已阅读并同意'.encode('utf-8').decode('cp1252','replace'))"
```

Then look inside `~/Games/<name>/prefix`:

- `system.reg`: `"ACP"="1252"` under `Nls\CodePage`; `user.reg`: `"LocaleName"="en-US"`.
- WebView2 launchers: `intl.selected_languages` in
  `.../AppData/Roaming/KRLauncher/*/KRWebViewUserData/EBWebView/Default/Preferences`.

The prefix inherited that from the shell's `LANG=en_US.UTF-8` when it was created. Give the launcher
a Chinese locale in `~/Games/<name>/conf` and restart it:

```bash
export LANG=zh_CN.UTF-8
```

`LANG` is the lever, not `LC_ALL`: Proton clears `LC_ALL` unless `HOST_LC_ALL` is set. Verify by
restarting the launcher -- the label should become readable Chinese. If it does not, the app is
producing those bytes itself and the fix belongs upstream.

## Silent install

`umu-install.nu <name> <setup.exe> <launcher> <gameid> /S` passes `/S` to the installer. Not all
installers honour it; try `/quiet` or `--silent` too, then fall back to the GUI.

## Desktop entry and persistence

The script also writes `~/.local/share/applications/<name>.desktop` (and a copy at
`~/Games/<name>/<name>.desktop`), so the game shows up in the desktop launcher. Under an
impermanence setup both `~/Games` and `~/.local/share/applications` must be in the host's
`preservation.preserveAt` list; in this repo `~/Games` and `.local/share/umu` already are, and
`hosts/idols-ai/preservation.nix` now persists `.local/share/applications` too.

## Uninstall

Run `~/Games/<name>/uninstall`: it removes the desktop entry and then asks before deleting
`~/Games/<name>` (prefix + game files). To keep the game and only drop the menu entry, delete the
`.desktop` file by hand.

## Optimize the launch

`~/Games/<name>/conf` (or `~/Games/global.conf`) is a shell file the generated `run` sources, with
defaults `ENABLE_GAMEMODE=0`, `ENABLE_GAMESCOPE=0`, `GAMESCOPE_ARGS="-f"`, and `ENABLE_LOG=0`. Set
`ENABLE_GAMESCOPE=1` + `GAMESCOPE_ARGS="-f -w 3840 -h 2160"` for the handheld / multi-monitor case,
`ENABLE_GAMEMODE=1` for gamemoderun, and `ENABLE_LOG=1` to capture the run. A dGPU wrapper still
goes outside: `nvidia-offload ~/Games/<name>/run`. Shader caches are kept in
`~/Games/<name>/shader-cache`.

## Escape hatches

- `~/Games/<name>/exec <exe-or-tool> [args...]` runs anything in the prefix with the right env: an
  absolute path to a game exe or repair tool, or a bare Wine tool (`winecfg`, `explorer`, `regedit`,
  `uninstaller`), which it routes through Proton wine.
- `~/Games/<name>/run <game args>` passes extra args to the launcher.
- Kill a stuck prefix with `pkill -f '/Games/<name>/prefix'`, or
  `rm -f ~/Games/<name>/prefix/pfx.lock`.

## Common mistakes

- Committing a game name, URL, or patch to this repo instead of `~/Games/<name>/`.
- Patching once instead of in `prelaunch` -- the next launcher self-update undoes it.
- Dropping the `GAMEID` -- the in-game CJK fonts and the save location go wrong.
- Installing more CJK fonts when the text is mojibake -- decode the bytes first (see above).
- Expecting umu to fetch DW-Proton: it only auto-manages GE-Proton / UMU-Proton; DW-Proton is
  `pkgs.dwproton-bin` and goes into `PROTONPATH` by path.
- `umu-run winecfg` directly does not work (umu only special-cases `winetricks`); use
  `~/Games/<name>/exec winecfg` or pass `$PROTONPATH/files/bin/wine winecfg`.
- Waiting for the game download before calling the install done: the launcher's own download is out
  of scope here.
- On NixOS a game needing 32-bit or Vulkan needs `hardware.graphics.enable32Bit`, and Steam is a
  module rather than a package -- see the `nix-config-desktop` skill.

## Prior art

`ESKAP3/umu-skeleton` (filesystem-as-game-manager, global.conf, tools), `gizmo-ds/endfield-run`
(`-exec` installer), `Septa-Serpenta-Seraph/Vesper` (umu + GAMEID notes), `joshsymonds/nix-config`
(research-first debugging), `olafkfreund/nixarchy` (NixOS gaming skill).

## Regression tests

From the repo root:

```bash
python3 .agents/skills/nix-config-umu-game/scripts/tests/test_install.py
```

Requires `python3`, `nu`, `bash`, and `shellcheck`. Uses temporary homes and a stub `umu-run`; no
game downloads, Wine windows, or changes to existing games. It checks template permissions, rendered
shell syntax and lint, installer arguments and failures, configuration precedence, prelaunch,
logging, launch wrappers, literal paths, runtime Proton overrides, tool routing, and uninstall
confirmation.

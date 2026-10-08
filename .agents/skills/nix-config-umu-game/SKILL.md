---
name: nix-config-umu-game
description:
  Use when installing a Windows game launcher (二次元 / gacha or any non-Steam game) on a NixOS
  desktop via umu-launcher, given an installer URL or an .exe, or when such a launcher opens an
  invisible, transparent, black, or empty window under Wine.
---

# Installing a Windows game launcher with umu

The bundled `scripts/umu-install.nu` is the only code this skill owns. It is generic: it creates a
prefix, runs the installer, and writes the launchers -- run it as-is; its `PROTONPATH`/`GAMEID`
handling is what makes this work. **Every per-game detail lives under `~/Games/`**, never in this
repo.

## Bundled files

| Path                     | What                               |
| ------------------------ | ---------------------------------- |
| `scripts/umu-install.nu` | the installer; run it, do not edit |

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

---
name: nix-config-umu-game
description:
  Use when installing a Windows game launcher (二次元 / gacha or any non-Steam game) on a NixOS
  desktop via umu-launcher, given an installer URL or an .exe, or when such a launcher opens an
  invisible, black, or empty window under Wine.
---

# Installing a Windows game launcher with umu

`just umu-install` is the only code this repo owns. It is generic: it creates a prefix, runs the
installer, and writes launchers. **Every per-game detail lives under `~/Games/`**, never in this
repo. This skill runs the whole flow for one game and leaves a working launcher.

## Layout

| Path                       | What                                                    |
| -------------------------- | ------------------------------------------------------- |
| `~/Games/global.conf`      | optional, sourced by every game before its own `conf`   |
| `~/Games/<name>/prefix`    | the Wine prefix (`WINEPREFIX`)                          |
| `~/Games/<name>/conf`      | optional per-game overrides (`ENABLE_GAMESCOPE=1`, ...) |
| `~/Games/<name>/prelaunch` | optional executable, run before every launch            |
| `~/Games/<name>/run`       | generated launcher                                      |
| `~/Games/<name>/exec`      | generated helper: `exec <exe-or-tool> [args...]`        |
| `~/Games/<name>/setup.exe` | the downloaded installer                                |

`just umu-install <name> <setup.exe> <launcher> [gameid]`, where `<launcher>` is relative to the
prefix and `GAMEID` defaults to `umu-default` (no protonfixes).

`PROTONPATH` is resolved from `$PROTONPATH`, then `$UMU_PROTONPATH` (exported by
`modules/nixos/desktop/gaming.nix` from `pkgs.dwproton-bin.steamcompattool`), then the newest
`dwproton` in `/nix/store`, then Steam's per-user `compatibilitytools.d`. The generated `run`/`exec`
re-read `$PROTONPATH`/`$UMU_PROTONPATH` at launch, so a Nix update is picked up without
regenerating.

## Procedure

1. **Research first.** Mandatory before inventing any fix: a documented fix beats a custom patch
   every time. Time-box it and check the game's Lutris installer YAML
   (`https://lutris.net/api/installers/<game-slug>`), which already encodes `winetricks` verbs,
   `write_file` content, and `prelaunch_command`; then ProtonDB (`protondb.com/app/<id>`), the Steam
   Community / r/linux_gaming threads, and GitHub issues for the launcher and Proton.
2. **Slug.** Pick a lowercase `<name>` (e.g. `wuthering-waves`); the prefix is
   `~/Games/<name>/prefix`.
3. **GAMEID.** The umu database maps a title to a `GAMEID` whose protonfixes add CJK fonts, drop the
   `SteamOS`/`SteamDeck` vars, and keep Wine's `Documents` inside the prefix. **Without it, some
   games save into the host home or the wrong prefix.** Fetch
   `https://raw.githubusercontent.com/Open-Wine-Components/umu-database/main/umu-database.csv` and
   match the title; use its `umu-<id>`. If nothing matches, leave the default.
4. **Download.** `curl -fL <url> -o ~/Games/<name>/setup.exe`. The CN store pages are JS/token
   driven, so the user normally supplies the URL or the file itself.
5. **Install.** Run `just umu-install <name> ~/Games/<name>/setup.exe <launcher> <gameid>`. The
   setup is usually a GUI, so the user clicks through it; everything after that is unattended. Exit
   the installer without starting the game.
6. **Find the launcher.** If `<launcher>` is only known after the install:
   `find ~/Games/<name>/prefix/drive_c -iname '*launcher*.exe'`, then re-run `just umu-install`
   (idempotent) or set `LAUNCHER` in `~/Games/<name>/conf`.
7. **Per-game fix.** Port step 1 findings into `~/Games/<name>/prelaunch` (bash, `chmod +x`):
   `winetricks` verbs via `~/Games/<name>/exec winetricks <verbs>`, file patches or registry tweaks
   via `~/Games/<name>/exec`. Never commit the fix to this repo.
8. **Re-run every launch, not once.** A launcher that self-updates overwrites files it patches, so
   those patches belong in `prelaunch`.
9. **Verify.** `~/Games/<name>/run` must open a visible launcher window and re-running `prelaunch`
   must be idempotent. When a launcher goes invisible, start it with `ENABLE_LOG=1` and read
   `~/Games/<name>/last-run.log`.

## Optimize the launch

`~/Games/<name>/conf` (or `~/Games/global.conf`) is a shell file the generated `run` sources, with
defaults `ENABLE_GAMEMODE=0`, `ENABLE_GAMESCOPE=0`, `GAMESCOPE_ARGS="-f"`, and `ENABLE_LOG=0`. Set
`ENABLE_GAMESCOPE=1` + `GAMESCOPE_ARGS="-f -w 3840 -h 2160"` for the handheld / multi-monitor case,
`ENABLE_GAMEMODE=1` for gamemoderun, and `ENABLE_LOG=1` to capture the run. A dGPU wrapper still
goes outside: `nvidia-offload ~/Games/<name>/run`. Shader caches are kept in
`~/Games/<name>/shader-cache`.

## Escape hatches

- `~/Games/<name>/exec <exe-or-tool> [args...]` runs anything inside the prefix with the right env:
  an absolute path to a game exe or repair tool, or a bare Wine tool (`winecfg`, `explorer`,
  `regedit`, `uninstaller`, which it routes through Proton wine).
- `~/Games/<name>/run <game args>` passes extra args to the launcher.
- Kill a stuck prefix with `pkill -f '/Games/<name>/prefix'`.

## Common mistakes

- Committing a game name, URL, or patch to this repo instead of `~/Games/<name>/`.
- Patching once instead of in `prelaunch` -- the next launcher self-update undoes it.
- Dropping the `GAMEID` -- the in-game CJK fonts and the save location go wrong.
- Expecting umu to fetch DW-Proton: it only auto-manages GE-Proton / UMU-Proton; DW-Proton is
  `pkgs.dwproton-bin` and goes into `PROTONPATH` by path.
- `umu-run winecfg` directly does not work (umu only special-cases `winetricks`); use
  `~/Games/<name>/exec winecfg` or pass `$PROTONPATH/files/bin/wine winecfg`.
- On NixOS a game needing 32-bit or Vulkan needs `hardware.graphics.enable32Bit`, and Steam is a
  module rather than a package -- see the `nix-config-desktop` skill.

## Prior art

`ESKAP3/umu-skeleton` (filesystem-as-game-manager, global.conf, tools), `gizmo-ds/endfield-run`
(`-exec` installer), `Septa-Serpenta-Seraph/Vesper` (umu + GAMEID notes), `joshsymonds/nix-config`
(research-first debugging), `olafkfreund/nixarchy` (NixOS gaming skill).

---
name: nix-config-umu-game
description:
  Use when installing a Windows game launcher (二次元 / gacha or any non-Steam game) on a NixOS
  desktop via umu-launcher, given an installer URL or an .exe, or when such a launcher opens an
  invisible, black, or empty window under Wine.
---

# Installing a Windows game launcher with umu

`just umu-install` is the only code this repo owns. It is generic: it creates a prefix, runs the
installer, and writes a launcher. **Every per-game detail lives under `~/Games/<name>/`**, never in
this repo. This skill runs the whole flow for one game and leaves a working launcher.

## Layout

| Path                       | What                                           |
| -------------------------- | ---------------------------------------------- |
| `~/Games/<name>/prefix`    | the Wine prefix (`WINEPREFIX`)                 |
| `~/Games/<name>/run`       | generated launcher: prefix + launcher + GAMEID |
| `~/Games/<name>/prelaunch` | optional executable, run before every launch   |
| `~/Games/<name>/setup.exe` | the downloaded installer                       |

`@bash just umu-install <name> <setup.exe> <launcher> [gameid] `@

`<launcher>` is relative to the prefix. Defaults: `PROTONPATH` is the Nix `dwproton-bin` tool at
`~/.local/share/Steam/compatibilitytools.d/dwproton`; `GAMEID` is `umu-default` (no fixes).

## Procedure

1. **Slug.** Pick a lowercase `<name>` (e.g. `wuthering-waves`); the prefix is
   `~/Games/<name>/prefix`.
2. **GAMEID.** The umu database maps a title to a `GAMEID` whose protonfixes add CJK fonts and drop
   the `SteamOS`/`SteamDeck` vars. Fetch
   `https://raw.githubusercontent.com/Open-Wine-Components/umu-database/main/umu-database.csv` and
   match the title; use its `umu-<id>`. If nothing matches, leave the default.
3. **Download.** `curl -fL <url> -o ~/Games/<name>/setup.exe`. The CN store pages are JS/token
   driven, so the user normally supplies the URL or the file itself.
4. **Install.** Run `just umu-install <name> ~/Games/<name>/setup.exe <launcher> <gameid>`. The
   setup is usually a GUI, so the user clicks through it; everything after that is unattended. Exit
   the installer without starting the game.
5. **Find the launcher.** If `<launcher>` is only known after the install:
   `find ~/Games/<name>/prefix/drive_c -iname '*launcher*.exe'`, then re-run `just umu-install`
   (idempotent) or edit `~/Games/<name>/run`.
6. **Per-game fix.** Do not invent one: Lutris already encodes the fixes for most games. Fetch its
   installer YAML from `https://lutris.net/api/installers/<game-slug>` (find the slug under
   `https://lutris.net/games/<slug>/`). Port its `winetricks` verbs to `umu-run winetricks <verbs>`,
   and its `write_file` / `system.env` / `prelaunch_command` into `~/Games/<name>/prelaunch` (bash,
   `chmod +x`).
7. **Re-run every launch, not once.** A launcher that self-updates overwrites files it patches, so
   those patches belong in `prelaunch`. The installer runs it right after install and the generated
   `run` runs it before every launch.
8. **Verify.** `~/Games/<name>/run` must open a visible launcher window and re-running `prelaunch`
   must be idempotent. Report the launch path and the dGPU/handheld wrapper:
   `steamdeck=1 gamescope -f -w 3840 -h 2160 -- ~/Games/<name>/run`.

## Common mistakes

- Committing a game name, URL, or patch to this repo instead of `~/Games/<name>/`.
- Patching once instead of in `prelaunch` -- the next launcher self-update undoes it.
- Dropping the `GAMEID` -- the in-game CJK fonts go missing.
- Expecting umu to fetch DW-Proton: it only auto-manages GE-Proton / UMU-Proton; DW-Proton is
  `pkgs.dwproton-bin` and goes into `PROTONPATH` by path.

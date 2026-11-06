---
name: nix-config-umu-game
description:
  Use when installing a Windows game launcher (二次元 / gacha or any non-Steam game) on a NixOS
  desktop via umu-launcher, given an installer URL or an .exe, when such a launcher opens an
  invisible, transparent, black, or empty window under Wine, or when its download crawls behind the
  proxy.
---

# Installing a Windows game launcher with umu

The bundled `scripts/umu-install.nu` renders the files in `scripts/templates/`. It creates a prefix,
runs the installer, and writes launchers. Use the Nix DW-Proton default unless research identifies a
specific installed release; then select it with `PROTONPATH` and pin that path in the game's `conf`.
**Every per-game detail lives under `~/Gaming/Games/`**, never in this repo.

## The sandbox

Games run only inside the umu nixpak sandbox (`hardening/nixpaks/umu.nix`, policy in
`hardening/nixpaks/modules/gaming-policy.nix`). It mounts `~/Gaming` over `$HOME`; no other host
file is visible or writable. `umu-run`, `winetricks` and `bbe` exist only inside it (`mangohud` and
`gamescope` are on the host too), and `umu-sandbox <command>` runs a command there.

**Two views of one path:** `~/Gaming/<path>` on the host is `~/<path>` in the sandbox, so a game
lives at `~/Gaming/Games/<name>` on the host and at `~/Games/<name>` inside. The host has no
`~/Games`: a path written that way is a sandbox path. Typed after `umu-sandbox` in a host shell,
`~/Games/<name>/run` expands to exactly that sandbox path. Host environment variables do not reach
the sandbox; put them in `conf`.

Everything under `~/Gaming` is writable by the games, so **the host never executes a file from it**:

- launch with `umu-sandbox ~/Games/<name>/run` and use `umu-sandbox ~/Games/<name>/exec ...`; the
  generated desktop entry does the former. Running `run` or `exec` directly refuses to start.
- the installer and `prelaunch` also run through `umu-sandbox`;
- `umu-install.nu` refuses to write through a symlink in the game directory and writes its files
  there through `umu-sandbox`, so a symlink swapped in later still cannot reach outside `~/Gaming`;
  uninstalling uses the repo's `umu-uninstall.nu`, not a script in `~/Gaming`.

## Bundled files

- `scripts/umu-install.nu`: installer and template renderer
- `scripts/umu-uninstall.nu`: removes a game's desktop entry and, after confirmation, its directory
- `scripts/common.nu`: name, symlink and sandbox-path helpers shared by both
- `scripts/templates/*.tpl`: non-executable templates; placeholders use `@NAME@`
- `scripts/tests/test_install.py`: offline regression tests

## Layout

Host paths; inside the sandbox drop the `Gaming/`.

- `~/Gaming`: the sandbox's `$HOME`, shared with the other game launchers (umu runtime, Steam,
  Heroic, saves written to `$HOME`)
- `~/Gaming/Games/global.conf`: optional, sourced by every game before its own `conf`
- `~/Gaming/Games/<name>/prefix`: the Wine prefix (`WINEPREFIX`)
- `~/Gaming/Games/<name>/conf`: optional per-game overrides (`ENABLE_MANGOHUD=0`, ...)
- `~/Gaming/Games/<name>/prelaunch`: optional executable, run before every launch
- `~/Gaming/Games/<name>/run`: generated launcher
- `~/Gaming/Games/<name>/exec`: generated helper: `umu-sandbox ~/Games/<name>/exec <exe-or-tool>`
- `~/Gaming/Games/<name>/<name>.desktop`: generated desktop entry

Run, from the repo root:

`nu .agents/skills/nix-config-umu-game/scripts/umu-install.nu <name> <setup.exe> <launcher> [gameid] [setup-args...]`

`<launcher>` is relative to the prefix and `GAMEID` defaults to `umu-default`. A `<setup.exe>`
outside `~/Gaming` is copied into the game directory first; `-` skips the installer and only
rewrites `run`, `exec` and the desktop entry. At install, `PROTONPATH` resolves from `$PROTONPATH`,
`$UMU_PROTONPATH` (the Nix-provided DW-Proton), then Steam's per-user `compatibilitytools.d` in the
sandbox home; it must be a store path or under `~/Gaming`. `run`, `exec` and the desktop entry hold
sandbox paths. At launch, the generated `run` script checks the current `$PROTONPATH` and
`$UMU_PROTONPATH` before its saved default. A game's `conf` is sourced after those defaults, so set
`PROTONPATH` there to pin a particular installed version across launches.

## Procedure

1. **Research first.** Mandatory before inventing any fix: a documented fix beats a custom patch
   every time. Check the game's Lutris installer YAML as data only
   (`https://lutris.net/api/installers/<game-slug>` encodes `winetricks` verbs, `write_file`
   content, and `prelaunch_command`; do not install or run Lutris), then ProtonDB
   (`protondb.com/app/<id>`), Steam Community / r/linux_gaming threads, and GitHub issues for the
   launcher and Proton. Record whether reports require a Proton family and exact release. If no
   exact release is required, use the Nix-provided DW-Proton default. If one is required, inspect
   `$UMU_PROTONPATH`, the Nix GE-Proton
   (`nix build --no-link --print-out-paths .#nixosConfigurations.<host>.pkgs.proton-ge-bin.steamcompattool`)
   and installed Steam tools under `~/Gaming/.local/share/Steam/compatibilitytools.d/` (the
   sandbox's `~/.local/share/Steam/compatibilitytools.d/`); select the matching installed path with
   `PROTONPATH`. Prefix the installer command with `PROTONPATH="<selected-tool-directory>"` and set
   its sandbox path (a store path as is; under `~/Gaming`, drop the `Gaming/`) in the game's `conf`
   to pin it across launches; otherwise the runtime Nix `UMU_PROTONPATH` may take precedence. If the
   required release is absent from Nix and Steam, stop and ask the user before downloading it from
   elsewhere. Do not substitute a different release or use ProtonPlus/Lutris to fetch one: a
   host-side downloader writes outside `~/Gaming`, where the sandbox cannot see it, and a store path
   cannot be modified by a game.
2. **Slug.** Pick a lowercase `<name>` (e.g. `wuthering-waves`).
3. **GAMEID.** The umu database maps a title to a `GAMEID` whose protonfixes add CJK fonts, drop the
   `SteamOS`/`SteamDeck` vars, and keep Wine's `Documents` inside the prefix. **Without it some
   games save into the host home or the wrong prefix.** Fetch
   `https://raw.githubusercontent.com/Open-Wine-Components/umu-database/main/umu-database.csv`,
   match the title, and use its `umu-<id>`; if nothing matches, leave the default.
4. **Download.** `curl -fL <url> -o ~/Gaming/Games/<name>/setup.exe`. The CN store pages are
   JS/token driven, so the user normally supplies the URL or the file itself.
5. **Install.** Run the bundled script. The first run also downloads umu's Steam runtime and the
   protonfix fonts, so it is slow. The installer is usually a GUI the user clicks through, but
   **extra args after `[gameid]` go to `setup.exe`**, so try a silent flag first (`/S`, `/quiet`,
   `--silent`); if it ignores them, fall back to clicking. On some CN installers the last page
   auto-starts the launcher. The script writes `run`/`exec` even if the installer exits non-zero, so
   a killed installer is not fatal.
6. **Find the launcher.** If `<launcher>` is only known after install, locate it under
   `~/Gaming/Games/<name>/prefix/drive_c` and set `LAUNCHER` in `~/Gaming/Games/<name>/conf`.
   Re-running the installer script invokes `setup.exe` again; only do so if that installer is known
   to handle reruns.
7. **Per-game fix.** Port step 1 findings into `~/Gaming/Games/<name>/prelaunch` (bash, `chmod +x`):
   `winetricks` verbs via `~/Games/<name>/exec winetricks <verbs>`, file patches or registry tweaks
   via `~/Games/<name>/exec`. `prelaunch` runs in the sandbox, so it uses sandbox paths and calls
   `exec` directly; from a host shell, prefix it with `umu-sandbox`. Never commit the fix to this
   repo.
8. **Re-run every launch, not once.** A launcher that self-updates overwrites files it patches, so
   those patches belong in `prelaunch`.
9. **Verify.** `umu-sandbox ~/Games/<name>/run` must open a visible launcher window. MangoHud is
   enabled by default with FPS and frame time at the top-left; set `ENABLE_MANGOHUD=0` in `conf` to
   disable it, or override `MANGOHUD_CONFIG`. Re-running `prelaunch` must be idempotent. The
   launcher may then download the game body itself (tens of GB) -- that is the launcher's job, not
   this skill's, so the install is **done** once the window is usable. A crawl usually means the
   proxy: the launcher probes the CDN itself and mihomo routes that probe through a distant node, so
   the download starts from a far mirror; routing is in the
   [mihomo README](../../../modules/nixos/desktop/networking/mihomo/README.md). `ENABLE_LOG=1`
   captures `last-run.log` when something misbehaves.

## Invisible / transparent launcher window

A WebView2/.NET (WPF) launcher that shows an empty or fully transparent window is rendering with
`AllowsTransparency`. Fix the DLL, not Wine:

1. `find ~/Gaming/Games/<name>/prefix/drive_c -iname 'launcher_main.dll'` (usually under a `X.Y.Z.W`
   version dir).
2. Rename that WPF property in place, keeping the byte length so PE offsets stay valid:
   `bbe -e 's/\x12AllowsTransparency/\x09IsEnabled\x1bA\x00\x03AAAAA/' <dll>`. `bbe` exists only in
   the sandbox: prefix it with `umu-sandbox` from a host shell.
3. Put it in `~/Gaming/Games/<name>/prelaunch` so it is re-applied on every launch, because a
   launcher self-update restores the original DLL. Restart the launcher after patching.

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

A launcher shares that app id with its game, so the rule also catches the launcher's own windows: a
helper that is still untitled while it maps, and the announcement popup (公告 / Announcement), which
on this launcher renders as a pure white rectangle. Fullscreening either one buries the UI that
opened it, so both are excluded. A window rule applies when a window opens, so an already-open
offender needs `Mod+Shift+F` on it or a relaunch; drop `open-fullscreen true` altogether if a
launcher keeps surprising you -- the game then costs one `Mod+Shift+F` per session instead.

## Mojibake that is not a missing font

Latin-looking garbage such as `æˆ‘å·²é˜…è¯»` where the launcher should say 我已阅读并同意, while
other Chinese on the same window renders fine, is UTF-8 decoded as Windows-1252. Confirm the
pattern:

```bash
python3 -c "print('我已阅读并同意'.encode('utf-8').decode('cp1252','replace'))"
```

If that prints exactly what the launcher shows, the bug is identified and you can stop here.

The string itself is fine and so are the fonts: the same launcher
renders 请输入手机号 and 登录 correctly, and the garbled label exists as correct UTF-16 in
`KRSDKEx.dll`. The bytes are simply decoded with a single-byte Western codepage.

**This is not the prefix locale.** Setting `LANG=zh_CN.UTF-8` in `~/Gaming/Games/<name>/conf` does
change the prefix (verified in this repo: `"ACP"` went `1252` -> `936` and `"LocaleName"` `en-US` ->
`zh-CN`), and the garbling stayed **byte-for-byte identical**. The launcher decodes those bytes as
Latin-1 no matter what Windows codepage it is told to use, so this is an upstream bug in its own
text pipeline: report it, or accept it -- the launcher still works. `LANG` is nevertheless the lever
for the prefix locale, not `LC_ALL`: Proton clears `LC_ALL` unless `HOST_LC_ALL` is set.

So: check the bytes first, do not install more CJK fonts, and do not promise a locale fix.

## Silent install

`umu-install.nu <name> <setup.exe> <launcher> <gameid> /S` passes `/S` to the installer. Not all
installers honour it; try `/quiet` or `--silent` too, then fall back to the GUI.

## Desktop entry and persistence

The script also writes `~/.local/share/applications/<name>.desktop` (and a copy at
`~/Gaming/Games/<name>/<name>.desktop`), so the game shows up in the desktop launcher. The host copy
is written by the installer on the host; the sandbox cannot see or change it. Under an impermanence
setup both `~/Gaming` and `~/.local/share/applications` must be in the host's
`preservation.preserveAt` list, in `hosts/<dir>/preservation.nix`.

## Uninstall

From the repo root:

`nu .agents/skills/nix-config-umu-game/scripts/umu-uninstall.nu <name>`

It removes the desktop entry, but only one whose `Exec` is the generated
`umu-sandbox ~/Games/<name>/run`, and then asks before deleting `~/Gaming/Games/<name>` (prefix +
game files). To keep the game and only drop the menu entry, delete the `.desktop` file by hand.

## Games installed before the sandbox

After deploying the sandbox and with every game closed, move `~/Games` to `~/Gaming/Games` and the
old `~/.local/share/umu` to `~/Gaming/.local/share/umu` (umu can also download its runtime again).
On a normal host that is a plain `mv`. On an impermanence host each preserved directory is its own
bind mount, and after the deploy the old ones are no longer mounted, so move them under the
persistent root instead, where both are renames:

```bash
mkdir -p /persistent/home/<user>/Gaming/.local/share
mv /persistent/home/<user>/Games /persistent/home/<user>/Gaming/Games
mv /persistent/home/<user>/.local/share/umu /persistent/home/<user>/Gaming/.local/share/umu
```

`/persistent` is the host's `preservation.preserveAt` root. If a target already exists, `mv` would
nest the source inside it: move the game directories one by one instead, and drop the old umu
runtime. Paths inside the game directories stay valid, because the sandbox sees them at the old
`~/Games/<name>`. The old desktop entries execute `run` on the host, and an old `uninstall` script
is host-executed too, so rewrite the launchers without re-running the installer, passing the
`LAUNCHER` and `GAMEID` from the old `run`:

`nu .agents/skills/nix-config-umu-game/scripts/umu-install.nu <name> - <launcher> <gameid>`

This also deletes the old `uninstall`.

## Optimize the launch

`~/Gaming/Games/<name>/conf` (or `~/Gaming/Games/global.conf`) is a shell file the generated `run`
sources. Defaults are `ENABLE_MANGOHUD=1`, `MANGOHUD_CONFIG="fps=1,frametime=1,position=top-left"`,
`ENABLE_GAMEMODE=0`, `ENABLE_GAMESCOPE=0`, `GAMESCOPE_ARGS="-f"`, and `ENABLE_LOG=0`. Set
`ENABLE_MANGOHUD=0` to hide the overlay, `ENABLE_GAMESCOPE=1` +
`GAMESCOPE_ARGS="-f -w 3840 -h 2160"` for the handheld / multi-monitor case, and `ENABLE_LOG=1` to
capture the run. Gamescope runs inside the sandbox without `CAP_SYS_NICE`, so it cannot raise its
own priority. `ENABLE_GAMEMODE=1` has no effect: `gamemoderun` is not in the sandbox, whose PID
namespace and D-Bus filter keep `gamemoded` from managing the game. A host wrapper such as
`nvidia-offload` does not work either, because the sandbox clears the environment; export its
variables (`__NV_PRIME_RENDER_OFFLOAD=1`, ...) in `conf` instead. Shader caches are kept in
`~/Gaming/Games/<name>/shader-cache`.

## Escape hatches

- `umu-sandbox ~/Games/<name>/exec <exe-or-tool> [args...]` runs anything in the prefix with the
  right env: an absolute path to a game exe or repair tool, or a bare Wine tool (`winecfg`,
  `explorer`, `regedit`, `uninstaller`), which it runs as `umu-run <Proton's wine> <tool>`. Both
  forms are handed to `umu-run`, so they execute inside umu's Steam runtime container -- that is
  what makes them work on a non-FHS distro like NixOS, where Proton's wine cannot start on its own.
- `umu-sandbox ~/Games/<name>/run <game args>` passes extra args to the launcher.
- Kill a stuck prefix with `pkill -f '/Games/<name>/prefix'`, or
  `rm -f ~/Gaming/Games/<name>/prefix/pfx.lock`.

## Common mistakes

- Launching again while the first launch after a Proton update or a moved umu runtime shows no
  window: it is preparing steamrt4 and upgrading the prefix, which can take a minute, and a second
  launch blocks on the same locks. Wait, or `pkill -f '/Games/<name>/prefix'` and launch once.
- Committing a game name, URL, or patch to this repo instead of `~/Gaming/Games/<name>/`.
- Patching once instead of in `prelaunch` -- the next launcher self-update undoes it.
- Dropping the `GAMEID` -- the in-game CJK fonts and the save location go wrong.
- Installing more CJK fonts when the text is mojibake -- decode the bytes first (see above).
- Expecting umu to fetch DW-Proton: it only auto-manages GE-Proton / UMU-Proton; use Nix or Steam
  installed paths. Ask the user before obtaining a required release from elsewhere.
- Running a Wine tool without umu. `umu-run winecfg` does not work -- umu only special-cases
  `winetricks` -- and `$PROTONPATH/files/bin/wine winecfg` fails on any non-FHS distro (on NixOS the
  32-bit loader it needs lives only inside the Steam runtime container). Use
  `umu-sandbox ~/Games/<name>/exec winecfg`; `exec` goes through `umu-run`, which provides that
  container.
- Running `run`, `exec` or `prelaunch` from a host shell, or adding a host-side helper that executes
  a file under `~/Gaming`: games can rewrite those files. Go through `umu-sandbox`.
- Pointing `PROTONPATH`, a launcher or an installer at a host path outside `~/Gaming`: the sandbox
  cannot see it. Inside `conf` and `prelaunch`, write sandbox paths (`~/Games/<name>`).
- Waiting for the game download before calling the install done: the launcher's own download is out
  of scope here.
- On NixOS a game needing 32-bit or Vulkan needs `hardware.graphics.enable32Bit`, which
  `modules/nixos/desktop/gaming.nix` sets. Steam is a sandboxed package like umu:
  `hardening/nixpaks/steam.nix`.

## Regression tests

From the repo root:

```bash
python3 .agents/skills/nix-config-umu-game/scripts/tests/test_install.py
```

Requires `python3`, `nu`, `bash`, and `shellcheck`; the symlink-swap test also needs `unshare` and
unprivileged user namespaces, and is skipped without them. Uses temporary homes and stub `umu-run`
and `umu-sandbox`; no game downloads, Wine windows, or changes to existing games. It checks template
permissions, rendered shell syntax and lint, installer arguments and failures, configuration
precedence, prelaunch, logging, launch wrappers, literal paths, runtime Proton overrides, tool
routing, uninstall confirmation and foreign desktop entries, the sandbox guard, host-to-sandbox path
translation, refusal to write through planted symlinks, and that a symlink swapped in after that
check cannot redirect a write outside `~/Gaming`.

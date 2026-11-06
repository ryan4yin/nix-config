"""Offline regression tests; needs nu, bash and shellcheck, but no Wine."""

import os
import subprocess
import tempfile
import unittest
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parents[1]


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="umu-test-")
        self.addCleanup(self.temp.cleanup)
        root = Path(self.temp.name)
        home = root / "home"
        home.mkdir()
        self.home = home
        bin_dir = root / "bin"
        bin_dir.mkdir()
        self.bin_dir = bin_dir
        self.proton = root / "store/proton"
        (self.proton / "files/bin").mkdir(parents=True)
        (self.proton / "proton").touch()
        self.log = root / "call"
        stub = bin_dir / "umu-run"
        stub.write_text("""#!/usr/bin/env bash
mkdir -p "$WINEPREFIX"
printf "%s\n" "$WINEPREFIX" "$PROTONPATH" "$GAMEID" "$@" > "$CALL_LOG"
exit "${STUB_EXIT:-0}"
""")
        stub.chmod(0o755)
        self.sandbox_log = root / "sandbox-call"
        sandbox = bin_dir / "umu-sandbox"
        sandbox.write_text("""#!/usr/bin/env bash
pwd >> "$SANDBOX_LOG"
export UMU_SANDBOX=1
exec "$@"
""")
        sandbox.chmod(0o755)
        self.mangohud_log = root / "mangohud-call"
        hud = bin_dir / "mangohud"
        hud.write_text("""#!/usr/bin/env bash
printf "%s\n" "${MANGOHUD_CONFIG-unset}" "$@" > "$MANGOHUD_LOG"
exec "$@"
""")
        hud.chmod(0o755)
        self.env = dict(
            os.environ,
            HOME=str(home),
            PROTONPATH=str(self.proton),
            CALL_LOG=str(self.log),
            SANDBOX_LOG=str(self.sandbox_log),
            # Stands in for /nix/store, which the sandbox can always read.
            NIX_STORE_DIR=str(root / "store"),
            MANGOHUD_LOG=str(self.mangohud_log),
            PATH=str(bin_dir) + os.pathsep + os.environ["PATH"],
        )
        for key in ("XDG_DATA_HOME", "BASH_ENV", "ENV", "UMU_PROTONPATH", "UMU_SANDBOX"):
            self.env.pop(key, None)
        self.use_home(home)
        self.launcher = "drive_c/Program Files/Test/launcher.exe"
        self.gameid = "umu-test"

    def use_home(self, home):
        self.home = home
        self.env["HOME"] = str(home)
        # The host side: umu-install.nu writes here.
        self.games = home / "Gaming/Games"
        self.game = self.games / "test-game"
        # The sandbox mounts ~/Gaming over $HOME. The stub umu-sandbox cannot
        # remap paths, so a symlink makes the sandbox paths written into the
        # launchers resolve on the host.
        self.sandbox_game = home / "Games/test-game"
        (home / "Games").symlink_to(self.games, target_is_directory=True)

    def invoke_install(self, name, setup="setup.exe", **extra):
        if setup == "setup.exe":
            (self.home / setup).touch()
        return subprocess.run(
            [
                "nu",
                str(SCRIPTS / "umu-install.nu"),
                name,
                setup,
                self.launcher,
                self.gameid,
                "/S",
            ],
            env=self.env | extra,
            cwd=self.home,
            capture_output=True,
            text=True,
            check=False,
        )

    def install(self, **extra):
        result = self.invoke_install("test-game", **extra)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def uninstall(self, name="test-game", input="n\n"):
        return subprocess.run(
            ["nu", str(SCRIPTS / "umu-uninstall.nu"), name],
            env=self.env,
            input=input,
            capture_output=True,
            text=True,
            check=False,
        )

    def call(self, name, *args, input=None):
        result = subprocess.run(
            [str(self.bin_dir / "umu-sandbox"), str(self.sandbox_game / name), *args],
            env=self.env,
            input=input,
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return self.log.read_text().splitlines()

    def test_name_must_be_one_slug_component_before_any_install_work(self):
        games = self.home / "Gaming"
        outside = self.home / "escaped"
        invalid_names = [str(outside), "../escaped", "nested/game", ".."]

        for name in invalid_names:
            with self.subTest(name=name):
                result = self.invoke_install(name)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("lowercase slug", result.stderr)
                self.assertFalse(self.log.exists())
                self.assertFalse(games.exists())
                self.assertFalse(outside.exists())

    def test_install_rejects_symlinked_roots(self):
        for root in (self.home / "Gaming", self.games):
            with self.subTest(root=root.name):
                root.parent.mkdir(parents=True, exist_ok=True)
                outside = self.home / f"outside-{root.name}"
                outside.mkdir()
                root.symlink_to(outside, target_is_directory=True)

                result = self.invoke_install("test-game")

                self.assertNotEqual(result.returncode, 0)
                self.assertIn("symlink", result.stderr)
                self.assertFalse(self.log.exists())
                self.assertEqual(list(outside.iterdir()), [])
                root.unlink()

    def test_uninstall_refuses_games_root_replaced_by_symlink(self):
        self.install()
        games = self.games
        relocated = self.home / "relocated-games"
        games.rename(relocated)
        games.symlink_to(relocated, target_is_directory=True)

        result = self.uninstall(input="y\n")

        self.assertNotEqual(result.returncode, 0)
        self.assertTrue((relocated / "test-game/run").exists())

    def test_install_rejects_symlinked_game_directory(self):
        games = self.games
        games.mkdir(parents=True)
        outside = self.home / "outside"
        outside.mkdir()
        (games / "test-game").symlink_to(outside, target_is_directory=True)

        result = self.invoke_install("test-game")

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("symlink", result.stderr)
        self.assertFalse(self.log.exists())
        self.assertEqual(list(outside.iterdir()), [])

    def test_install_rejects_symlinked_prefix(self):
        game = self.game
        game.mkdir(parents=True)
        outside = self.home / "outside"
        outside.mkdir()
        (game / "prefix").symlink_to(outside, target_is_directory=True)

        result = self.invoke_install("test-game")

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("symlink", result.stderr)
        self.assertFalse(self.log.exists())
        self.assertEqual(list(outside.iterdir()), [])

    def test_install_rejects_dangling_symlink_prefix(self):
        game = self.game
        game.mkdir(parents=True)
        outside = self.home / "missing-prefix-target"
        (game / "prefix").symlink_to(outside, target_is_directory=True)

        result = self.invoke_install("test-game")

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("symlink", result.stderr)
        self.assertFalse(self.log.exists())
        self.assertFalse(outside.exists())

    def test_uninstall_refuses_directory_moved_outside_games(self):
        self.install()
        outside = self.home / "outside"
        self.game.rename(outside)
        self.game.symlink_to(outside, target_is_directory=True)

        result = self.uninstall(input="y\n")

        self.assertNotEqual(result.returncode, 0)
        self.assertTrue(outside.exists())
        self.assertTrue((outside / "run").exists())

    def test_templates_are_separate_and_non_executable(self):
        for name in (
            "run.sh.tpl",
            "exec.sh.tpl",
            "launcher.desktop.tpl",
        ):
            path = SCRIPTS / "templates" / name
            self.assertTrue(path.is_file(), str(path))
            self.assertFalse(os.access(path, os.X_OK), str(path))

    def test_run_enables_minimal_top_left_mangohud_by_default(self):
        self.install()

        self.call("run")

        hud_call = self.mangohud_log.read_text().splitlines()
        self.assertEqual(hud_call[0], "fps=1,frametime=1,position=top-left")
        self.assertEqual(
            hud_call[1:], ["umu-run", str(self.sandbox_game / "prefix" / self.launcher)]
        )

    def test_run_can_disable_mangohud_per_game(self):
        self.install()
        (self.game / "conf").write_text("ENABLE_MANGOHUD=0\n")

        values = self.call("run")

        self.assertFalse(self.mangohud_log.exists())
        self.assertEqual(values[3:], [str(self.sandbox_game / "prefix" / self.launcher)])

    def test_generation_and_setup_arguments(self):
        self.install()
        self.assertEqual(
            self.log.read_text().splitlines()[3:],
            [str(self.sandbox_game / "setup.exe"), "/S"],
        )
        self.assertFalse((self.game / "uninstall").exists())
        for name in ("run", "exec"):
            path = self.game / name
            self.assertTrue(os.access(path, os.X_OK))
            subprocess.run(["bash", "-n", str(path)], check=True)
            subprocess.run(["shellcheck", str(path)], check=True)
        desktop = self.home / ".local/share/applications/test-game.desktop"
        self.assertIn("Name=Test Game", desktop.read_text())
        self.assertIn(
            "Exec=umu-sandbox " + str(self.sandbox_game / "run"), desktop.read_text()
        )
        self.assertEqual(
            desktop.read_bytes(), (self.game / "test-game.desktop").read_bytes()
        )

    def test_nonzero_installer_still_generates_launchers(self):
        self.install(STUB_EXIT="7")
        self.assertTrue((self.game / "run").exists())

    def test_config_prelaunch_and_launch_arguments(self):
        self.install()
        (self.game.parent / "global.conf").write_text('GAMEID="global"\n')
        (self.game / "conf").write_text('GAMEID="local"\nENABLE_LOG=1\n')
        prelaunch = self.game / "prelaunch"
        prelaunch.write_text('#!/usr/bin/env bash\ntouch "$WINEPREFIX/../patched"\n')
        prelaunch.chmod(0o755)
        self.install()
        values = self.call("run", "--game-arg")
        self.assertEqual(values[2], "local")
        self.assertEqual(
            values[3:],
            [str(self.sandbox_game / "prefix" / self.launcher), "--game-arg"],
        )
        self.assertTrue((self.game / "patched").exists())
        self.assertTrue((self.game / "last-run.log").exists())

    def test_launcher_path_is_quoted_as_data(self):
        self.launcher = "drive_c/quote'\"$HOME/launcher.exe"
        self.install()
        values = self.call("run")
        self.assertEqual(values[3:], [str(self.sandbox_game / "prefix" / self.launcher)])

    def test_values_containing_placeholder_text_are_not_rerendered(self):
        home = self.home.parent / "@GAMEID@"
        home.mkdir()
        self.use_home(home)
        self.launcher = "drive_c/@PROTONPATH@/launcher.exe"
        self.gameid = "$(printf injected)"
        self.install()
        values = self.call("run")
        self.assertEqual(values[0], str(self.sandbox_game / "prefix"))
        self.assertEqual(values[3], str(self.sandbox_game / "prefix" / self.launcher))

    def test_game_conf_pins_installed_proton_over_system_default(self):
        self.install()
        selected = self.home / "steam-dwproton"
        system_default = self.home / "system-dwproton"
        (selected / "files/bin").mkdir(parents=True)
        (selected / "proton").touch()
        (system_default / "files/bin").mkdir(parents=True)
        (system_default / "proton").touch()
        (self.game / "conf").write_text(f"PROTONPATH='{selected}'\n")
        self.env.pop("PROTONPATH")
        self.env["UMU_PROTONPATH"] = str(system_default)

        self.assertEqual(self.call("run")[1], str(selected))

    def test_runtime_proton_override(self):
        self.install()
        self.env["PROTONPATH"] = str(self.home / "override")
        self.assertEqual(self.call("run")[1], self.env["PROTONPATH"])
        self.assertEqual(
            self.call("exec", "winecfg")[3], str(self.home / "override/files/bin/wine")
        )

    def test_gamemode_and_gamescope_wrappers(self):
        self.install()
        gamemode_log = self.home / "gamemode.log"
        gamescope_log = self.home / "gamescope.log"
        self.env.update(WRAPPER_LOG=str(gamemode_log), GAMESCOPE_LOG=str(gamescope_log))
        wrappers = {
            "gamemoderun": '#!/usr/bin/env bash\nprintf "called\\n" > "$WRAPPER_LOG"\nexec "$@"\n',
            "gamescope": '#!/usr/bin/env bash\nprintf "%s\\n" "$@" > "$GAMESCOPE_LOG"\nwhile [ "$1" != -- ]; do shift; done\nshift\nexec "$@"\n',
        }
        for name, script in wrappers.items():
            path = self.bin_dir / name
            path.write_text(script)
            path.chmod(0o755)
        (self.game / "conf").write_text(
            'ENABLE_GAMEMODE=1\nENABLE_GAMESCOPE=1\nGAMESCOPE_ARGS="-f -w 1920"\n'
        )
        self.call("run")
        self.assertEqual(gamemode_log.read_text(), "called\n")
        self.assertEqual(
            gamescope_log.read_text().splitlines()[:6],
            ["-f", "-w", "1920", "--", "mangohud", "umu-run"],
        )

    def test_exec_routes_wine_tools(self):
        self.install()
        self.assertEqual(
            self.call("exec", "winecfg")[3:],
            [str(self.proton / "files/bin/wine"), "winecfg"],
        )
        self.assertEqual(
            self.call("exec", "/tmp/tool.exe", "argument")[3:],
            ["/tmp/tool.exe", "argument"],
        )

    def test_uninstall_confirmation(self):
        self.install()
        desktop = self.home / ".local/share/applications/test-game.desktop"
        result = self.uninstall(input="n\n")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue(self.game.exists())
        self.assertFalse(desktop.exists())
        result = self.uninstall(input="y\n")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertFalse(self.game.exists())

    def test_run_refuses_to_start_outside_the_sandbox(self):
        self.install()
        self.log.unlink()
        for name in ("run", "exec"):
            with self.subTest(name=name):
                result = subprocess.run(
                    [str(self.game / name), "winecfg"],
                    env=self.env,
                    capture_output=True,
                    text=True,
                    check=False,
                )
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("umu-sandbox", result.stderr)
                self.assertFalse(self.log.exists())

    def test_installer_and_prelaunch_run_in_the_sandbox(self):
        self.game.mkdir(parents=True)
        prelaunch = self.game / "prelaunch"
        prelaunch.write_text('#!/usr/bin/env bash\n[ "$UMU_SANDBOX" = 1 ]\n')
        prelaunch.chmod(0o755)
        self.install()
        # Both start in the home, which exists on the host and in the sandbox.
        self.assertEqual(
            self.sandbox_log.read_text().splitlines(), [str(self.home), str(self.home)]
        )

    def test_rewrite_launchers_without_installer(self):
        result = self.invoke_install("test-game", setup="-")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertFalse(self.log.exists())
        self.assertTrue((self.game / "run").exists())

    def test_old_uninstall_script_is_removed(self):
        self.game.mkdir(parents=True)
        (self.game / "uninstall").write_text("#!/bin/sh\n")
        self.install()
        self.assertFalse((self.game / "uninstall").exists())

    def test_install_refuses_to_write_through_planted_symlinks(self):
        target = self.home / "bashrc"
        target.write_text("host file\n")
        for name in ("run", "exec", "test-game.desktop", "setup.exe"):
            with self.subTest(name=name):
                self.game.mkdir(parents=True, exist_ok=True)
                link = self.game / name
                link.unlink(missing_ok=True)
                link.symlink_to(target)
                result = self.invoke_install("test-game")
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("symlink", result.stderr)
                self.assertEqual(target.read_text(), "host file\n")
                link.unlink()

    def test_installer_in_the_sandbox_home_is_used_in_place(self):
        setup = self.home / "Gaming/Downloads/setup.exe"
        setup.parent.mkdir(parents=True)
        setup.touch()
        self.install_from(setup)
        self.assertEqual(
            self.log.read_text().splitlines()[3], str(self.home / "Downloads/setup.exe")
        )
        self.assertFalse((self.game / "setup.exe").exists())

    def test_steam_proton_fallback_is_translated(self):
        proton = self.home / "Gaming/.local/share/Steam/compatibilitytools.d/dwproton"
        (proton / "files/bin").mkdir(parents=True)
        (proton / "proton").touch()
        self.env.pop("PROTONPATH")
        self.install()
        self.assertEqual(
            self.log.read_text().splitlines()[1],
            str(self.home / ".local/share/Steam/compatibilitytools.d/dwproton"),
        )

    def test_proton_outside_the_sandbox_is_rejected(self):
        self.env["NIX_STORE_DIR"] = str(self.home / "store")
        result = self.invoke_install("test-game")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("cannot see PROTONPATH", result.stderr)
        self.assertFalse(self.log.exists())

    def install_from(self, setup):
        result = self.invoke_install("test-game", setup=str(setup))
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

if __name__ == "__main__":
    unittest.main()

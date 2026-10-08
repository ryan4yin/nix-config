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
        self.proton = root / "proton"
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
        self.env = dict(
            os.environ,
            HOME=str(home),
            UMU_GAMES_DIR=str(home / "Games"),
            PROTONPATH=str(self.proton),
            CALL_LOG=str(self.log),
            PATH=str(bin_dir) + os.pathsep + os.environ["PATH"],
        )
        for key in ("XDG_DATA_HOME", "BASH_ENV", "ENV"):
            self.env.pop(key, None)
        self.game = home / "Games/test-game"
        self.launcher = "drive_c/Program Files/Test/launcher.exe"
        self.gameid = "umu-test"

    def install(self, **extra):
        result = subprocess.run(
            [
                "nu",
                str(SCRIPTS / "umu-install.nu"),
                "test-game",
                "setup.exe",
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
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def call(self, name, *args, input=None):
        result = subprocess.run(
            [str(self.game / name), *args],
            env=self.env,
            input=input,
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return self.log.read_text().splitlines()

    def test_templates_are_separate_and_non_executable(self):
        for name in (
            "run.sh.tpl",
            "exec.sh.tpl",
            "uninstall.sh.tpl",
            "launcher.desktop.tpl",
        ):
            path = SCRIPTS / "templates" / name
            self.assertTrue(path.is_file(), str(path))
            self.assertFalse(os.access(path, os.X_OK), str(path))

    def test_generation_and_setup_arguments(self):
        self.install()
        self.assertEqual(self.log.read_text().splitlines()[3:], ["setup.exe", "/S"])
        for name in ("run", "exec", "uninstall"):
            path = self.game / name
            self.assertTrue(os.access(path, os.X_OK))
            subprocess.run(["bash", "-n", str(path)], check=True)
            subprocess.run(["shellcheck", str(path)], check=True)
        desktop = self.home / ".local/share/applications/test-game.desktop"
        self.assertIn("Name=Test Game", desktop.read_text())
        self.assertIn("Exec=" + str(self.game / "run"), desktop.read_text())
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
            values[3:], [str(self.game / "prefix" / self.launcher), "--game-arg"]
        )
        self.assertTrue((self.game / "patched").exists())
        self.assertTrue((self.game / "last-run.log").exists())

    def test_launcher_path_is_quoted_as_data(self):
        self.launcher = "drive_c/quote'\"$HOME/launcher.exe"
        self.install()
        values = self.call("run")
        self.assertEqual(values[3:], [str(self.game / "prefix" / self.launcher)])

    def test_values_containing_placeholder_text_are_not_rerendered(self):
        games = self.home / "@GAMEID@"
        self.env["UMU_GAMES_DIR"] = str(games)
        self.game = games / "test-game"
        self.launcher = "drive_c/@PROTONPATH@/launcher.exe"
        self.gameid = "$(printf injected)"
        self.install()
        values = self.call("run")
        self.assertEqual(values[0], str(self.game / "prefix"))
        self.assertEqual(values[3], str(self.game / "prefix" / self.launcher))

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
            gamescope_log.read_text().splitlines()[:5],
            ["-f", "-w", "1920", "--", "umu-run"],
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
        self.call("uninstall", input="n\n")
        self.assertTrue(self.game.exists())
        self.assertFalse(desktop.exists())
        subprocess.run(
            [str(self.game / "uninstall")],
            env=self.env,
            input="y\n",
            text=True,
            check=True,
            capture_output=True,
        )
        self.assertFalse(self.game.exists())


if __name__ == "__main__":
    unittest.main()

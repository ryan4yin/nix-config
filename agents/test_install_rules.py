import importlib.util
import io
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


spec = importlib.util.spec_from_file_location(
    "install_rules", Path(__file__).with_name("install-rules.py")
)
installer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(installer)


class InstallRulesTests(unittest.TestCase):
    def test_target_failure_does_not_stop_remaining_targets(self):
        with (
            patch.object(
                installer, "install_one", side_effect=[PermissionError("denied"), None, None, None]
            ) as install,
            patch("sys.stderr", new_callable=io.StringIO) as stderr,
        ):
            self.assertEqual(installer.main(), 1)
            self.assertEqual(install.call_count, 4)
            self.assertIn("denied", stderr.getvalue())

    def test_successful_targets_return_success(self):
        with patch.object(installer, "install_one") as install:
            self.assertEqual(installer.main(), 0)
            self.assertEqual(install.call_count, 4)

    def test_existing_file_is_backed_up_without_overwriting_backup(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "source.md"
            source.write_text("global rules")
            target = root / "AGENTS.md"
            target.write_text("personal rules")
            backup = root / "AGENTS.md.bak"
            backup.write_text("older rules")
            installer.install_one(root, source, target.name)
            self.assertEqual(target.resolve(), source)
            self.assertEqual(backup.read_text(), "older rules")
            self.assertEqual((root / "AGENTS.md.bak.1").read_text(), "personal rules")

    def test_failed_link_creation_preserves_existing_file(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "source.md"
            source.write_text("global rules")
            target = root / "AGENTS.md"
            target.write_text("personal rules")
            with patch.object(Path, "symlink_to", side_effect=OSError("link failed")):
                with self.assertRaises(OSError):
                    installer.install_one(root, source, target.name)
            self.assertTrue(target.is_file())
            self.assertFalse(target.is_symlink())
            self.assertEqual(target.read_text(), "personal rules")


if __name__ == "__main__":
    unittest.main()

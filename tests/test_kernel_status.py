import importlib.util
import os
import tempfile
import unittest
from pathlib import Path
from unittest import mock

SCRIPT = Path(__file__).resolve().parent.parent / "scripts" / "kernel-status.py"


class KernelStatusTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        spec = importlib.util.spec_from_file_location("kernel_status", SCRIPT)
        cls.reporter = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(cls.reporter)

    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.first = self.root / "kernel-one"
        self.second = self.root / "kernel-two"
        self.first.touch()
        self.second.touch()

    def test_same_kernel_through_different_symlinks_needs_no_reboot(self):
        current = self.root / "current"
        booted = self.root / "booted"
        current.symlink_to(self.first)
        booted.symlink_to(self.first)
        metrics = self.reporter.render_metrics(current, booted)
        self.assertIn("nixos_kernel_status_success 1\n", metrics)
        self.assertIn("nixos_kernel_reboot_required 0\n", metrics)

    def test_different_kernel_images_require_reboot_even_without_version_labels(self):
        metrics = self.reporter.render_metrics(self.first, self.second)
        self.assertIn("nixos_kernel_status_success 1\n", metrics)
        self.assertIn("nixos_kernel_reboot_required 1\n", metrics)

    def test_missing_booted_kernel_reports_unknown_not_healthy(self):
        missing = self.root / "missing"
        metrics = self.reporter.render_metrics(self.first, missing)
        self.assertIn("nixos_kernel_status_success 0\n", metrics)
        self.assertNotIn("nixos_kernel_reboot_required", metrics)

    def test_broken_symlink_reports_unknown(self):
        broken = self.root / "broken"
        broken.symlink_to(self.root / "absent")
        self.assertIn(
            "nixos_kernel_status_success 0\n",
            self.reporter.render_metrics(broken, self.first),
        )

    def test_metrics_are_atomic_readable_and_leave_no_temporary_files(self):
        output = self.root / "kernel-status.prom"
        output.write_text("old report\n")
        self.reporter.write_metrics(output, "new report\n")
        self.assertEqual(output.read_text(), "new report\n")
        self.assertEqual(os.stat(output).st_mode & 0o777, 0o644)
        self.assertEqual(
            sorted(p.name for p in self.root.iterdir()),
            ["kernel-one", "kernel-status.prom", "kernel-two"],
        )

    def test_failed_replace_preserves_previous_report_and_cleans_temporary_file(self):
        output = self.root / "kernel-status.prom"
        output.write_text("previous report\n")
        # Inject an OS rename failure, not a substitute implementation of the
        # reporter. Temp creation/writes and previous-file checks use real files.
        with (
            mock.patch.object(
                self.reporter.os, "replace", side_effect=OSError("rename failed")
            ),
            self.assertRaises(OSError),
        ):
            self.reporter.write_metrics(output, "new report\n")
        self.assertEqual(output.read_text(), "previous report\n")
        self.assertEqual(
            sorted(p.name for p in self.root.iterdir()),
            ["kernel-one", "kernel-status.prom", "kernel-two"],
        )


if __name__ == "__main__":
    unittest.main()

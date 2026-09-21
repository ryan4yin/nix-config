{
  ...
}:
{
  # Part 1 of the backup plan: a local restic repository on this machine.
  # The off-machine target (youko, or a cloud) is a later step.
  #
  # Be specific here and keep `exclude` minimal: an allowlist of the few
  # directories that are actually irreplaceable beats backing up a broad tree
  # and excluding half of it. Project checkouts under ~/codes are tracked in
  # git (or have remotes), so they are not backed up at all.
  modules.restic-backup = {
    enable = true;
    repository = "/var/lib/backups/restic/idols-ai";

    paths = [
      "/home/ryan/Documents"
      "/home/ryan/work"
      "/home/ryan/Pictures"
      "/home/ryan/nix-config"
      "/home/ryan/.local/state"
    ];

    exclude = [
      # generic patterns only; this repository is public
      "**/node_modules"
      "**/target"
      "**/.venv"
      "**/venv"
      "**/.next"
      "**/dist"
      "**/build"
      "**/.direnv"
      "**/result*"
      "**/__pycache__"
      "**/.pytest_cache"
      "**/.ruff_cache"
    ];
  };
}

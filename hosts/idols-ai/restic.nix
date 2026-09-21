{
  config,
  ...
}:
{
  # Part 1 of the backup plan: a local restic repository on this machine.
  # The off-machine target (youko, or a cloud) is a later step.
  #
  # Be specific here and keep `exclude` minimal: an allowlist of the
  # irreplaceable directories beats backing up a broad tree and excluding half
  # of it. Large files anywhere are skipped by size (excludeLargerThan), which
  # catches re-downloadable artifacts (models, datasets, archives) without
  # guessing file types or project names.
  # Back up to the homelab backup server (youko) over its restic REST server.
  # A repository on this machine would die with it. The repository password is
  # desktop-only (the server holds the homelab one, not this); the REST
  # credentials come from a systemd EnvironmentFile so they stay out of the URL.
  modules.restic-backup = {
    enable = true;
    repository = "rest:https://restic.writefor.fun/idols-ai/";
    environmentFile = config.age.secrets."restic-rest-credentials".path;

    paths = [
      "/home/ryan/Documents"
      "/home/ryan/work"
      "/home/ryan/Pictures"
      "/home/ryan/codes"
      "/home/ryan/nix-config"
      "/home/ryan/.local/state"
    ];

    # anything bigger than this is a re-downloadable artifact (models, datasets,
    # archives); a size cap beats guessing file types
    excludeLargerThan = "500M";

    exclude = [
      # Generic patterns only; this repository is public.
      #
      # node / JS
      "**/node_modules"
      "**/.next"
      "**/dist"
      # rust
      "**/target"
      # c / c++
      "**/CMakeFiles"
      "**/cmake-build-*"
      "**/compile_commands.json"
      # python
      "**/__pycache__"
      "**/*.egg-info"
      "**/.venv"
      "**/venv"
      "**/site-packages"
      "**/.pytest_cache"
      "**/.mypy_cache"
      "**/.ruff_cache"
      "**/.tox"
      "**/.nox"
      # go
      "**/vendor"
      # generic build dirs and tooling
      "**/build"
      "**/.direnv"
      "**/result*"
      "**/.terraform"
      # model weights in the common formats, and language caches
      "**/*.gguf"
      "**/*.ggml"
      "**/*.safetensors"
      "**/*.pth"
      "**/*.pt"
      "**/*.ckpt"
      "**/*.onnx"
      "**/*.h5"
      "**/*.keras"
      "**/*.tflite"
      "**/.cache"
      # git object packs: re-fetchable from the remotes
      "**/.git/objects/pack"
    ];
  };
}

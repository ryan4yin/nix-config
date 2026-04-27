# Default interactive editor is Helix (`hx`). For trust-boundary edits (e.g. `sudoedit`,
# secrets, unfamiliar payloads), prefer `nvim --clean` — wired via `SUDO_EDITOR`.
{
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
    SUDO_EDITOR = "nvim --clean";
  };
}

# Default editor is Helix (`hx`) for both interactive and privileged (`sudoedit`) edits. Set
# `$SUDO_EDITOR` explicitly instead of relying on the `$VISUAL`/`$EDITOR` fallback, so the
# privileged editor is unambiguous. Neovim stays installed as a backup editor.
{
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
    SUDO_EDITOR = "hx";
  };
}

# Default interactive editor is Helix (`hx`), for interactive and privileged (`sudoedit`) edits
# alike. `sudoedit` reads `$SUDO_EDITOR`, then `$VISUAL`, then `$EDITOR`, so it already resolves to
# `hx`. Neovim stays installed as a backup editor.
{
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };
}

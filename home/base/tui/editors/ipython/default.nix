{ ... }:
{
  # Interactive IPython sessions routinely handle credentials and other
  # sensitive values, so keep the SQLite history disabled rather than relying
  # on the profile directory's lifetime. Home Manager recreates these files
  # from the Nix store on every activation.
  home.file = {
    ".ipython/profile_default/ipython_config.py".text = ''
      c = get_config()
      c.HistoryManager.enabled = False
    '';
    ".ipython/profile_default/startup/10-data-helpers.py".source = ./data-helpers.py;
  };
}

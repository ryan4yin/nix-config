{ ... }:
{
  # Interactive IPython sessions routinely handle credentials and other
  # sensitive values, so keep the SQLite history in memory instead of on disk:
  # arrow-key recall and %history still work within a session, but no history
  # file is written. Home Manager recreates these files from the Nix store on
  # every activation.
  home.file = {
    ".ipython/profile_default/ipython_config.py".text = ''
      c = get_config()
      c.HistoryManager.hist_file = ":memory:"
    '';
    ".ipython/profile_default/startup/10-data-helpers.py".source = ./data-helpers.py;
  };
}

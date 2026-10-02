{ ... }:
let
  shellAliases = {
    k = "kubectl";
  };
in
{
  # Kept only for the `~/.profile` it generates: that file sources `hm-session-vars.sh`,
  # and the terminals launch `bash --login -c 'nu ...'`, so it is how `home.sessionVariables`
  # reach nushell. Bash itself needs no env/alias setup here — nushell owns those, and a bash
  # spawned from within nushell inherits the environment.
  programs.bash.enable = true;

  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    inherit shellAliases;
  };
}

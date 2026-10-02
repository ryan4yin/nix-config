{ ... }:
let
  shellAliases = {
    k = "kubectl";

    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
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

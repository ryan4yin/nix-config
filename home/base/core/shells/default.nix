{ config, ... }:
let
  shellAliases = {
    k = "kubectl";

    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
  };

  localBin = "${config.home.homeDirectory}/.local/bin";
  goBin = "${config.home.homeDirectory}/go/bin";
  rustBin = "${config.home.homeDirectory}/.cargo/bin";
  npmBin = "${config.home.homeDirectory}/.npm/bin";
in
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:${localBin}:${goBin}:${rustBin}:${npmBin}"
    '';
  };

  # NOTE: only works in bash/zsh, not nushell
  home.shellAliases = shellAliases;

  # NOTE: nushell will be launched in bash, so it can inherit all the eenvironment variables.
  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    inherit shellAliases;
  };
}

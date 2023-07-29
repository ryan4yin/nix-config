{ config, ...}: {
  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;

    extraConfig = ''
      let-env PATH = ([
        "${config.home.homeDirectory}/bin"
        "${config.home.homeDirectory}/.local/bin"
        "${config.home.homeDirectory}/go/bin"

        ($env.PATH | split row (char esep))
      ] | flatten)
    '';

    # home-manager will merge the cotent in `environmentVariables` with the `envFile.source`
    # but basically, I set all environment variables via the shell-independent way, so I don't need to use those two options
    #
    # envFile.source = ./env.nu;
    # environmentVariables = { FOO="bar"; };

    shellAliases = {
      k = "kubectl";

      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
  };
}

{...}: {
  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;

    # home-manager will merge the cotent in `environmentVariables` with the `envFile.source`
    # but basically, I set all environment variables via the shell-independent way, so I don't need to use those two options
    # 
    # envFile.source = ./env.nu;
    # environmentVariables = { FOO="bar"; };

    shellAliases = {
      k = "kubectl";
      vim = "nvim";

      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
      httpproxy = "let-env https_proxy = http://127.0.0.1:7890; let-env http_proxy = http://127.0.0.1:7890;";
    };
  };
}
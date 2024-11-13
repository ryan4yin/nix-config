{pkgs, ...}: {
  programs.foot = {
    # foot is designed only for Linux
    enable = pkgs.stdenv.isLinux;
    # https://man.archlinux.org/man/foot.ini.5
    settings = {
      main = {
        term = "foot"; # or "xterm-256color" for maximum compatibility
        font = "JetBrainsMono Nerd Font:size=14";
        dpi-aware = "yes";

        # Spawn a nushell in login mode via `bash`
        shell = "${pkgs.bash}/bin/bash --login -c 'nu --login --interactive'";
      };

      mouse = {
        hide-when-typing = "yes";
      };

      # https://github.com/catppuccin/foot/blob/main/themes/catppuccin-mocha.ini
      cursor = {
        color = "11111b f5e0dc";
      };
      colors = {
        alpha = "0.93"; # background opacity

        foreground = "cdd6f4";
        background = "1e1e2e";

        regular0 = "45475a";
        regular1 = "f38ba8";
        regular2 = "a6e3a1";
        regular3 = "f9e2af";
        regular4 = "89b4fa";
        regular5 = "f5c2e7";
        regular6 = "94e2d5";
        regular7 = "bac2de";

        bright0 = "585b70";
        bright1 = "f38ba8";
        bright2 = "a6e3a1";
        bright3 = "f9e2af";
        bright4 = "89b4fa";
        bright5 = "f5c2e7";
        bright6 = "94e2d5";
        bright7 = "a6adc8";

        "16" = "fab387";
        "17" = "f5e0dc";

        "selection-foreground" = "cdd6f4";
        "selection-background" = "414356";

        "search-box-no-match" = "11111b f38ba8";
        "search-box-match" = "cdd6f4 313244";

        "jump-labels" = "11111b fab387";
        urls = "89b4fa";
      };
    };
  };
}

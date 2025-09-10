{
  pkgs,
  anyrun,
  ...
}:
{
  programs.anyrun = {
    enable = true;
    config = {
      # The horizontal position.
      # when using `fraction`, it sets a fraction of the width or height of the screen
      x.fraction = 0.5; # at the middle of the screen
      # The vertical position.
      y.fraction = 0.05; # at the top of the screen
      # The width of the runner.
      width.fraction = 0.3; # 30% of the screen

      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = false;
      closeOnClick = true;
      showResultsImmediately = true;
      maxEntries = null;

      # https://github.com/anyrun-org/anyrun/tree/master/plugins
      plugins = with anyrun.packages.${pkgs.system}; [
        applications # Launch applications
        dictionary # Look up word definitions using the Free Dictionary API.
        nix-run # search & run graphical apps from nixpkgs via `nix run`, without installing it.
        # randr         # quickly change monitor configurations on the fly
        rink # A simple calculator plugin
        symbols # Look up unicode symbols and custom user defined symbols.
        translate # ":zh <text to translate>" Quickly translate text using the Google Translate API.
        niri-focus # Search for & focus the window via title/appid on Niri
      ];
    };

    extraConfigFiles."applications.ron".text = ''
      Config(
        // Also show the Desktop Actions defined in the desktop files, e.g. "New Window" from LibreWolf
        desktop_actions: true,

        max_entries: 5,

        // The terminal used for running terminal based desktop entries, if left as `None` a static list of terminals is used
        // to determine what terminal to use.
        terminal: Some(Terminal(
          // The main terminal command
          command: "alacritty",
          // What arguments should be passed to the terminal process to run the command correctly
          // {} is replaced with the command in the desktop entry
          args: "-e {}",
        )),
      )
    '';

    extraConfigFiles."symbols.ron".text = ''
      Config(
        // The prefix that the search needs to begin with to yield symbol results
        prefix: "",
        // Custom user defined symbols to be included along the unicode symbols
        symbols: {
          // "name": "text to be copied"
          "shrug": "¯\\_(ツ)_/¯",
        },
        max_entries: 3,
      )
    '';

    # https://github.com/anyrun-org/anyrun/discussions/179
    extraCss = ''
      /* GTK Vars */
      @define-color bg-color #313244;
      @define-color fg-color #cdd6f4;
      @define-color primary-color #89b4fa;
      @define-color secondary-color #cba6f7;
      @define-color border-color @primary-color;
      @define-color selected-bg-color @primary-color;
      @define-color selected-fg-color @bg-color;

      * {
        all: unset;
        font-family: JetBrainsMono Nerd Font;
      }

      #window {
        background: transparent;
      }

      box#main {
        border-radius: 16px;
        background-color: alpha(@bg-color, 0.8);
        border: 0.5px solid alpha(@fg-color, 0.25);
      }

      entry#entry {
        font-size: 1.25rem;
        background: transparent;
        box-shadow: none;
        border: none;
        border-radius: 16px;
        padding: 16px 24px;
        min-height: 40px;
        caret-color: @primary-color;
      }

      list#main {
        background-color: transparent;
      }

      #plugin {
        background-color: transparent;
        padding-bottom: 4px;
      }

      #match {
        font-size: 1.1rem;
        padding: 2px 4px;
      }

      #match:selected,
      #match:hover {
        background-color: @selected-bg-color;
        color: @selected-fg-color;
      }

      #match:selected label#info,
      #match:hover label#info {
        color: @selected-fg-color;
      }

      #match:selected label#match-desc,
      #match:hover label#match-desc {
        color: alpha(@selected-fg-color, 0.9);
      }

      #match label#info {
        color: transparent;
        color: @fg-color;
      }

      label#match-desc {
        font-size: 1rem;
        color: @fg-color;
      }

      label#plugin {
        font-size: 16px;
      }
    '';
  };
}

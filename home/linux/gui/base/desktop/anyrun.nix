{
  pkgs,
  anyrun,
  ...
}:

let
  anyrunPackages = anyrun.packages.${pkgs.system};
in
{

  imports = [
    (
      { modulesPath, ... }:
      {
        # Important! We disable home-manager's module to avoid option
        # definition collisions
        disabledModules = [ "${modulesPath}/programs/anyrun.nix" ];
      }
    )
    anyrun.homeManagerModules.default
  ];

  programs.anyrun = {
    enable = true;
    # The package should come from the same flake as all the plugins to avoid breakage.
    package = anyrunPackages.anyrun;
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
      plugins = with anyrunPackages; [
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

    extraConfigFiles = {
      "symbols.ron".source = ./conf/anyrun/symbols.ron;
      "applications.ron".source = ./conf/anyrun/applications.ron;
    };
  };

  # https://github.com/anyrun-org/anyrun/discussions/179
  xdg.configFile."anyrun/style.css".source = ./conf/anyrun/style.css;
}

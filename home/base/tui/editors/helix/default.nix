{ pkgs, helix, ... }:

let
  helixPackages = helix.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages = with pkgs; [
    steel
  ];

  programs.helix = {
    enable = true;
    # https://github.com/helix-editor/helix/pull/8675
    package = helixPackages.default.overrideAttrs (prevAttrs: {
      # enable steel as the plugin system
      cargoBuildFeatures = prevAttrs.cargoBuildFeatures or [ ] ++ [ "steel" ];
    });
    settings = {
      editor = {
        line-number = "relative";
        cursorline = true;
        color-modes = true;
        lsp.display-messages = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides.render = true;
      };
      keys.normal = {
        space = {
          space = "file_picker";
          w = ":w";
          q = ":q";
        };
        esc = [
          "collapse_selection"
          "keep_primary_selection"
        ];
      };
    };
  };
}

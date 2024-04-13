{
  config,
  lib,
  pkgs,
  ...
}:
###############################################################################
#
#  AstroNvim's configuration and all its dependencies(lsp, formatter, etc.)
#
#e#############################################################################
let
  shellAliases = {
    v = "nvim";
    vdiff = "nvim -d";
  };
in {
  home.activation.installAstroNvim = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 ${./nvim}/ ${config.xdg.configHome}/nvim/
  '';

  home.shellAliases = shellAliases;
  programs.nushell.shellAliases = shellAliases;

  programs = {
    neovim = {
      enable = true;

      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      # currently we use lazy.nvim as neovim's package manager, so comment this one.
      # Install packages that will compile locally or download FHS binaries via Nix!
      # and use lazy.nvim's `dir` option to specify the package directory in nix store.
      # so that these plugins can work on NixOS.
      #
      # related project:
      #  https://github.com/b-src/lazy-nix-helper.nvim
      plugins = with pkgs.vimPlugins; [
        # search all the plugins using https://search.nixos.org/packages
        telescope-fzf-native-nvim
      ];
    };
  };
}

{
  pkgs,
  astronvim,
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
  xdg.configFile = {
    # astronvim's config
    "nvim" = {
      source = astronvim;
      force = true;
    };

    # my custom astronvim config, astronvim will load it after base config
    # https://github.com/AstroNvim/AstroNvim/blob/v3.32.0/lua/astronvim/bootstrap.lua#L15-L16
    "astronvim/lua/user" = {
      source = ./astronvim_user;
      force = true;
    };
  };

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

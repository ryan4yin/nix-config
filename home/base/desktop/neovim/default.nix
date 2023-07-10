{ config, lib, inputs, pkgs, ... }:

# references:
#   https://github.com/nvimdev/dope
#   https://github.com/Ruixi-rebirth/flakes/tree/main/modules/editors/nvim
#   https://github.com/Chever-John/dotfiles/tree/master/nvim
#
# after apply, the first time you run nvim, it will download all configs into `.local/share/nvim`
{
  home.file = {
    ".config/nvim/bin".source = ./bin;
    ".config/nvim/lua".source = ./lua;
    ".config/nvim/snippets".source = ./snippets;
    ".config/nvim/static".source = ./static;
    ".config/nvim/init.lua".source = ./init.lua;
  };

  nixpkgs.config = {
    programs.npm.npmrc = ''
      prefix = ''${HOME}/.npm-global
    '';
  };

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;

      viAlias = false;
      vimAlias = true;
      
      withPython3 = true;
      withNodeJs = true;
      extraPackages = [];

      #-- Plugins --#
      # currently we use lazy.nvim as neovim's package manager, so comment this one.
      # plugins = with pkgs.vimPlugins;[
        # search all the plugins using https://search.nixos.org/packages
        # catppuccin-nvim  # https://github.com/catppuccin/nvim
        # nvim-treesitter.withAllGrammars
      # ];
    };
  };
  home = {
    packages = with pkgs; [
      # -- Compiler -- #
      gcc # c/c++ compiler, required by nvim-treesitter!
      llvmPackages.clang-unwrapped # c/c++ tools with clang-tools such as clangd
      zig
      go
      luajit

      #-- LSP --#
      nodePackages_latest.typescript
      nodePackages_latest.typescript-language-server
      nodePackages_latest.vscode-langservers-extracted
      nodePackages_latest.bash-language-server

      nil
      # rnix-lsp
      # nixd
      
      lua-language-server
      gopls
      pyright
      rust-analyzer

      #-- tree-sitter --#
      tree-sitter
      
      #-- format --#
      stylua
      black
      nixpkgs-fmt
      rustfmt
      beautysh
      nodePackages.prettier

      #-- Debug --#
      gdb
      lldb
    ];
  };

}

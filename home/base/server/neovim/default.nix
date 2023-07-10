{ config, lib, inputs, pkgs, ... }:

# references:
#   https://github.com/Ruixi-rebirth/flakes/tree/main/modules/editors/nvim
#   https://github.com/Chever-John/dotfiles/tree/master/nvim
{
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
      extraPackages = [
      ];
      #-- Plugins --#
      plugins = with pkgs.vimPlugins;[ ];
      #-- --#
    };
  };
  home = {
    packages = with pkgs; [
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
      zk
      rust-analyzer
      clang-tools
      haskell-language-server
      #-- tree-sitter --#
      tree-sitter
      #-- format --#
      stylua
      black
      nixpkgs-fmt
      rustfmt
      beautysh
      nodePackages.prettier
      stylish-haskell
      #-- Debug --#
      lldb
    ];
  };

  home.file.".config/nvim/init.lua".source = ./init.lua;
  home.file.".config/nvim/lua".source = ./lua;
}

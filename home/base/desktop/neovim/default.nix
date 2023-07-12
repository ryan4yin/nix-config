{ pkgs, astronvim, ... }:

# related folders:
# nvim's config: `~/.config/nvim`
# astronvim's user configuration: `$XDG_CONFIG_HOME/astronvim/lua/user`
# all plugins will be installed into(by lazy.nvim): `~/.local/share/nvim/`
# for details: https://astronvim.com/
{
  xdg.configFile = {
    # base config
    "nvim" = {
      # update AstroNvim
      onChange = "${pkgs.neovim}/bin/nvim --headless +quitall";
      source = astronvim;  
    };
    # my cusotom astronvim config, astronvim will load it after base config
    # https://github.com/AstroNvim/AstroNvim/blob/v3.32.0/lua/astronvim/bootstrap.lua#L15-L16
    "astronvim/lua/user/init.lua" = {
      # update AstroNvim
      onChange = "${pkgs.neovim}/bin/nvim --headless +quitall";
      source = ./astronvim_user_init.lua;
    };
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

      # currently we use lazy.nvim as neovim's package manager, so comment this one.
      # plugins = with pkgs.vimPlugins;[
        # search all the plugins using https://search.nixos.org/packages
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
      cargo  # rust package manager

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

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
      plugins = with pkgs.vimPlugins;[
        # search all the plugins using https://search.nixos.org/packages
        luasnip

      ];
    };
  };
  home = {
    packages = with pkgs; [
      #-- c/c++
      cmake
      gnumake
      gcc # c/c++ compiler, required by nvim-treesitter!
      llvmPackages.clang-unwrapped # c/c++ tools with clang-tools such as clangd
      gdb
      lldb

      #-- python
      nodePackages.pyright # python language server
      python311Packages.black   # python formatter
      python311Packages.ruff-lsp
      
      #-- rust
      rust-analyzer
      cargo  # rust package manager
      rustfmt

      #-- nix
      nil
      rnix-lsp
      # nixd
      statix     # Lints and suggestions for the nix programming language
      deadnix    # Find and remove unused code in .nix source files
      alejandra  # Nix Code Formatter
      # nixpkgs-fmt

      #-- golang
      go
      iferr  # generate error handling code for go
      impl   # generate function implementation for go
      gotools  # contains tools like: godoc, goimports, etc.
      gopls  # go language server
      delve  # go debugger

      #-- lua
      luajit
      stylua
      luajitPackages.luarocks
      luajitPackages.luacheck
      lua-language-server

      #-- bash
      nodePackages.bash-language-server
      shellcheck
      shfmt
      
      #-- javascript/typescript --#
      nodePackages.typescript
      nodePackages.typescript-language-server
      # HTML/CSS/JSON/ESLint language servers extracted from vscode
      nodePackages.vscode-langservers-extracted

      #-- cloudnative
      nodePackages.dockerfile-language-server-nodejs
      terraform
      terraform-ls
      jsonnet
      jsonnet-language-server

      #-- others
      taplo  # TOML language server / formatter / validator
      nodePackages.yaml-language-server

      # common
      tree-sitter            # common language parser/highlighter
      nodePackages.prettier  # common code formatter
    ];
  };

}

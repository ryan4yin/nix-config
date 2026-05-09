{ config, nixvim, ... }:
{

  imports = [ nixvim.homeModules.nixvim ];
  home.shellAliases = {

    vi = "nvim";
    vim = "nvim";
  };

  programs.nixvim = {
    enable = true;

    clipboard.providers.wl-copy.enable = true;

    opts = {
      number = true;
      relativenumber = true;
      cursorline = true;
      signcolumn = "auto";
      clipboard = "unnamedplus";
      scrolloff = 8;
      swapfile = false;
      title = true;
      titlelen = 20;
      smartindent = false;
      mouse = "a";
      undofile = true;
      ignorecase = true;
      smartcase = true;
      splitbelow = true;
      splitright = true;
      updatetime = 300;
      wrap = true;
      linebreak = true;
    };

    colorschemes.catppuccin = {
      enable = true;
      settings = {
        transparent_background = true;
      };
    };

    plugins.lsp.servers = {
      nixd.enable = true;
      "rust_analyzer" = {
        enable = true;
        installCargo = false;
        installRustc = false;
      };
      gopls.enable = true;
      pyright.enable = true;
      bashls.enable = true;
    };

    plugins.treesitter = {
      enable = true;
      grammarPackages = with config.programs.nixvim.plugins.treesitter.package.builtGrammars; [
        bash
        json
        lua
        make
        markdown
        nix
        regex
        rust
        go
        python
        toml
        vim
        vimdoc
        xml
        yaml
        nu
      ];
    };

    plugins.neo-tree = {
      enable = true;
      settings = {
        filesystem = {
          filtered_items = {
            visible = true;
            hide_dotfiles = false;
            hide_gitignored = false;
          };
          follow_current_file = {
            enabled = true;
            leave_dirs_open = false;
          };
        };
      };
    };
  };
}

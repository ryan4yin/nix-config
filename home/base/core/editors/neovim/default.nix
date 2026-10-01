{
  pkgs,
  ...
}:
let
  # Parsers are bundled into the plugin, so no runtime `:TSInstall` is needed.
  # Add a language here to get its treesitter highlighting and queries.
  treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (
    p: with p; [
      bash
      go
      json
      lua
      make
      markdown
      nix
      nu
      python
      regex
      rust
      toml
      vim
      vimdoc
      xml
      yaml
    ]
  );
in
{
  # Neovim config, ported from the old `programs.nixvim` block. The colorscheme
  # itself comes from `home/base/core/theme.nix` (catppuccin.nvim is enabled
  # there and appends its own plugin + setup).
  #
  # The plain system package (modules/base/packages.nix) stays in place for
  # privileged edits: `sudo` uses the system PATH, so
  # `$SUDO_EDITOR = "nvim --clean"` keeps this user config out of root-owned
  # files.
  programs.neovim = {
    enable = true;
    vimAlias = true;

    # No python/ruby plugins are configured; use the new explicit defaults
    # instead of the legacy providers (and their deprecation warnings).
    withPython3 = false;
    withRuby = false;

    # Language servers started by `vim.lsp.enable` below; each must be on $PATH.
    extraPackages = with pkgs; [
      bash-language-server
      gopls
      nixd
      pyright
      rust-analyzer
    ];

    plugins = [
      pkgs.vimPlugins.neo-tree-nvim
      pkgs.vimPlugins.nvim-lspconfig
      pkgs.vimPlugins.nvim-web-devicons
      treesitter
    ];

    initLua = ''
      -- Editor options (previously `programs.nixvim.opts`).
      local opt = vim.opt
      opt.number = true
      opt.relativenumber = true
      opt.cursorline = true
      opt.signcolumn = "auto"
      opt.clipboard = "unnamedplus"
      opt.scrolloff = 8
      opt.swapfile = false
      opt.title = true
      opt.titlelen = 20
      opt.smartindent = false
      opt.mouse = "a"
      opt.undofile = true
      opt.ignorecase = true
      opt.smartcase = true
      opt.splitbelow = true
      opt.splitright = true
      opt.updatetime = 300
      opt.wrap = true
      opt.linebreak = true

      -- Treesitter highlighting; parsers come from the bundled plugin.
      -- `pcall` skips filetypes that have no parser available.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })

      -- LSP: nvim-lspconfig ships the server definitions, Neovim starts them.
      vim.lsp.enable({ "nixd", "rust_analyzer", "gopls", "pyright", "bashls" })

      -- File explorer.
      require("neo-tree").setup({
        filesystem = {
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
          },
          follow_current_file = {
            enabled = true,
            leave_dirs_open = false,
          },
        },
      })
    '';
  };

  # Matches the old `programs.nixvim.colorschemes.catppuccin.settings`.
  catppuccin.nvim.settings.transparent_background = true;
}

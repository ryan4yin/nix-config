{
  pkgs,
  astronvim,
  ...
}:
###############################################################################
#
#  AstroNvim's configuration and all its dependencies
#
#  Related folders:
#    nvim's config: `~/.config/nvim`
#    astronvim's user configuration: `$XDG_CONFIG_HOME/astronvim/lua/user`
#    all plugins will be installed into(by lazy.nvim): `~/.local/share/nvim/`
#
#  For details: https://astronvim.com/
#
#  Toggle visual mode:              `v`
#  Toggle visual block mode:        `<Ctrl> + v`  (select a block(vertically) of text)
#
#  Add at the end of Multiple line: `:normal A<text>`
#      Note that `:normal` execute `A<text>` on each line.
#      `A` means append text at the end of the line.
#      You need to select the lines via visual mode first.
#
#  Add at the end of the visual block: `:A<text>`
#      You need to select the block via visual block mode first.
#      And then this command will append text at the end of the block on each line.
#      If the position exceeds the end of the line, neovim will automatically add spaces
#
#  Commands & shortcuts in AstroNvim
#    Learn Neovim's Basics:         `:Tutor`
#    Opening file explorer:         `<Space> + e`
#    Focus Neotree to current file: `<Space> + o`
#    Floating Terminal:	            `<Space> + tf`
#    Horizontal Split Terminal:	    `<Space> + th`
#    Vertical Split Terminal:	      `<Space> + tv`
#    Open IPython REPL:             `<Space> + tp`
#    Opening LSP symbols:           `<Space> + lS`
#    Toggle line wrap:              `<Space> + uw`
#    Show line diagnostics:         `gl`
#    Go to definition:              `gd`
#
#    Switching between windows:     `<Ctrl> + h/j/k/l`
#    Resizing windows:              `<Ctrl> + Up/Down/Left/Right`
#        Note that on macOS, this is conflict with system's default shortcuts.
#        You need disable them in System Preferences -> Keyboard -> Shortcuts -> Mission Control.
#    Horizontal Split:              `\`
#    Vertical Split:                `|`
#    Next Buffer(Tab):              `]b`
#    Previous Buffer(Tab):          `[b`
#    Close Buffer:                  `<Space> + c`
#
#    Toggle buffer auto formatting: `<Space> + uf`
#    Format Document:               `<Space> + lf`
#    Comment Line:                  `<Space> + /`
#        Can be used in visual mode
#    Code Actions:                  `<Space> + la`
#    Rename:                        `<Space> + lr`
#    Open filepath/URL at cursor:   `gx`
#        This is a neovim builtin command
#    Find files by name(fzf):       `<Space> + ff`
#    Grep string in files(repgrep): `<Space> + fw`
#
#    Save Session:                  `<Space> + Ss`
#    Last Session:                  `<Space> + Sl`
#    Delete Session:                `<Space> + Sd`
#    Search Session:                `<Space> + Sf`
#    Load Current Directory Session:`<Space> + S.`
#
#    Debugging: press `<Space> + D` to see the available bindings and options.
#
#    Replace in the selected area:  `:s/old/new/g`  (will show `:'<,'>s/old/new/g`)
#    Replace in the current line:   The same as above
#    Replace in the whole file:     `:% s/old/new/g`
#    Replace with regex:            `:% s@\vhttp://(\w+)@https://\1@gc`
#        1. `\v` means means that in the regex pattern after it can be used without backslash escaping(similar to python's raw string).
#        2. `\1` means the first matched group in the pattern.
#    Replace in the specific lines:
#        1. From the 10th line to the end of the file:     `:10,$ s/old/new/g`
#                                                       or `:10,$ s@^@#@g`
#        2. From the 10th line to the 20th line:           `:10,20 s/old/new/g`
#
#    The postfix(flgas) in the above commands:
#        1. `g` means replace all the matched strings in the current line/file.
#        2. `c` means ask for confirmation before replacing.
#        3. `i` means ignore case.
#
#    Joining a Selection of Lines With Space:  `:join`
#    Joining without spaces:                   `:join!`
#
#    Toggle text's case:                       `~`
#    Convert to uppercase:                     `U`
#    Convert to lowercase:                     `u`
#
#    Save the selected text to a file:         `:w filename`  (will show `:'<,'>w filename`)
#
#    Search key pattern and Replace in Multiple Files:
#        sed -ri "s/pattern_str/replace_str/g" $(grep "key_pattern" 'path_pattern' -rl)
#
#    Search file name pattern and Replace in Multiple Files:
#        sed -ri "s/pattern_str/replace_str/g" $(find . -name "pattern")
#
#    ......
#    See https://astronvim.com/Basic%20Usage/walkthrough
#
#e#############################################################################
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
    "astronvim/lua/user" = {
      # update AstroNvim
      onChange = "${pkgs.neovim}/bin/nvim --headless +quitall";
      source = ./astronvim_user;
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
      plugins = with pkgs.vimPlugins; [
        # search all the plugins using https://search.nixos.org/packages
        luasnip
      ];
    };
  };
  home = {
    packages = with pkgs; [
      #-- c/c++
      cmake
      cmake-language-server
      gnumake
      checkmake
      gcc # c/c++ compiler, required by nvim-treesitter!
      llvmPackages.clang-unwrapped # c/c++ tools with clang-tools such as clangd
      gdb
      lldb

      #-- python
      nodePackages.pyright # python language server
      python311Packages.black # python formatter
      python311Packages.ruff-lsp

      #-- rust
      rust-analyzer
      cargo # rust package manager
      rustfmt

      #-- zig
      zls

      #-- nix
      nil
      rnix-lsp
      # nixd
      statix # Lints and suggestions for the nix programming language
      deadnix # Find and remove unused code in .nix source files
      alejandra # Nix Code Formatter

      #-- golang
      go
      gomodifytags
      iferr # generate error handling code for go
      impl # generate function implementation for go
      gotools # contains tools like: godoc, goimports, etc.
      gopls # go language server
      delve # go debugger

      #-- lua
      stylua
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
      nodePackages."@tailwindcss/language-server"

      #-- CloudNative
      nodePackages.dockerfile-language-server-nodejs
      terraform
      terraform-ls
      jsonnet
      jsonnet-language-server
      hadolint # Dockerfile linter

      #-- Others
      taplo # TOML language server / formatter / validator
      nodePackages.yaml-language-server
      sqlfluff # SQL linter
      actionlint # GitHub Actions linter
      buf # protoc plugin for linting and formatting
      proselint # English prose linter

      #-- Misc
      tree-sitter # common language parser/highlighter
      nodePackages.prettier # common code formatter
      marksman # language server for markdown
      glow # markdown previewer

      #-- Optional Requirements:
      gdu # disk usage analyzer, required by AstroNvim
      ripgrep # fast search tool, required by AstroNvim's '<leader>fw'(<leader> is space key)
    ];
  };
}

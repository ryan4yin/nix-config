{pkgs, ...}: {
  nixpkgs.config = {
    programs.npm.npmrc = ''
      prefix = ''${HOME}/.npm-global
    '';
  };

  home.packages = with pkgs;
    [
      #-- c/c++
      cmake
      cmake-language-server
      gnumake
      checkmake
      # c/c++ compiler, required by nvim-treesitter!
      gcc
      # c/c++ tools with clang-tools, the unwrapped version won't
      # add alias like `cc` and `c++`, so that it won't conflict with gcc
      llvmPackages.clang-unwrapped
      lldb

      #-- python
      nodePackages.pyright # python language server
      (python311.withPackages (
        ps:
          with ps; [
            ruff-lsp
            black # python formatter

            jupyter
            ipython
            pandas
            requests
            pyquery
            pyyaml

            ## emacs's lsp-bridge dependenciesge
            epc
            orjson
            sexpdata
            six
            setuptools
            paramiko
            rapidfuzz
          ]
      ))

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

      # -- java
      jdk17
      gradle
      maven
      spring-boot-cli

      #-- lua
      stylua
      lua-language-server

      #-- bash
      nodePackages.bash-language-server
      shellcheck
      shfmt

      #-- javascript/typescript --#
      nodePackages.nodejs
      nodePackages.typescript
      nodePackages.typescript-language-server
      # HTML/CSS/JSON/ESLint language servers extracted from vscode
      nodePackages.vscode-langservers-extracted
      nodePackages."@tailwindcss/language-server"
      emmet-ls

      #-- CloudNative
      nodePackages.dockerfile-language-server-nodejs
      # terraform  # install via brew on macOS
      terraform-ls
      jsonnet
      jsonnet-language-server
      hadolint # Dockerfile linter

      # -- Lisp like Languages
      guile
      racket-minimal
      fnlfmt # fennel

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
      fzf
      pandoc # document converter
      hugo # static site generator

      #-- Optional Requirements:
      gdu # disk usage analyzer, required by AstroNvim
      (ripgrep.override {withPCRE2 = true;}) # recursively searches directories for a regex pattern
    ]
    ++ (
      lib.optionals pkgs.stdenv.isLinux [
        #-- verilog / systemverilog
        verible
        gdb
      ]
    );
}

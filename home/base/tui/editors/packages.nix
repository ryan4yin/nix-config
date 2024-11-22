{
  pkgs,
  pkgs-unstable,
  ...
}: {
  nixpkgs.config = {
    programs.npm.npmrc = ''
      prefix = ''${HOME}/.npm-global
    '';
  };

  home.packages = with pkgs; (
    # -*- Data & Configuration Languages -*-#
    [
      #-- nix
      nil
      # rnix-lsp
      # nixd
      statix # Lints and suggestions for the nix programming language
      deadnix # Find and remove unused code in .nix source files
      alejandra # Nix Code Formatter

      #-- nickel lang
      nickel

      #-- json like
      # terraform  # install via brew on macOS
      terraform-ls
      jsonnet
      jsonnet-language-server
      taplo # TOML language server / formatter / validator
      nodePackages.yaml-language-server
      actionlint # GitHub Actions linter

      #-- dockerfile
      hadolint # Dockerfile linter
      nodePackages.dockerfile-language-server-nodejs

      #-- markdown
      marksman # language server for markdown
      glow # markdown previewer
      pandoc # document converter
      pkgs-unstable.hugo # static site generator

      #-- sql
      sqlfluff

      #-- protocol buffer
      buf # linting and formatting
    ]
    ++
    #-*- General Purpose Languages -*-#
    [
      #-- c/c++
      cmake
      cmake-language-server
      gnumake
      checkmake
      # c/c++ compiler, required by nvim-treesitter!
      gcc
      gdb
      # c/c++ tools with clang-tools, the unwrapped version won't
      # add alias like `cc` and `c++`, so that it won't conflict with gcc
      # llvmPackages.clang-unwrapped
      clang-tools
      lldb
      vscode-extensions.vadimcn.vscode-lldb.adapter # codelldb - debugger

      #-- python
      pyright # python language server
      (python311.withPackages (
        ps:
          with ps; [
            ruff
            black # python formatter
            # debugpy

            # my commonly used python packages
            jupyter
            ipython
            pandas
            requests
            pyquery
            pyyaml
            boto3

            ## emacs's lsp-bridge dependenciesge
            # epc
            # orjson
            # sexpdata
            # six
            # setuptools
            # paramiko
            # rapidfuzz
          ]
      ))

      #-- rust
      # we'd better use the rust-overlays for rust development
      pkgs-unstable.rustc
      pkgs-unstable.rust-analyzer
      pkgs-unstable.cargo # rust package manager
      pkgs-unstable.rustfmt
      pkgs-unstable.clippy # rust linter

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
      jdt-language-server

      #-- zig
      zls

      #-- lua
      stylua
      lua-language-server

      #-- bash
      nodePackages.bash-language-server
      shellcheck
      shfmt
    ]
    #-*- Web Development -*-#
    ++ [
      nodePackages.nodejs
      nodePackages.typescript
      nodePackages.typescript-language-server
      # HTML/CSS/JSON/ESLint language servers extracted from vscode
      nodePackages.vscode-langservers-extracted
      nodePackages."@tailwindcss/language-server"
      emmet-ls
    ]
    # -*- Lisp like Languages -*-#
    ++ [
      guile
      racket-minimal
      fnlfmt # fennel
      (
        if pkgs.stdenv.isDarwin
        then pkgs.emptyDirectory
        else pkgs-unstable.akkuPackages.scheme-langserver
      )
    ]
    ++ [
      proselint # English prose linter

      #-- verilog / systemverilog
      verible

      #-- Optional Requirements:
      nodePackages.prettier # common code formatter
      fzf
      gdu # disk usage analyzer, required by AstroNvim
      (ripgrep.override {withPCRE2 = true;}) # recursively searches directories for a regex pattern
    ]
  );
}

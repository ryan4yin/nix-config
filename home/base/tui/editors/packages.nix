{
  pkgs,
  pkgs-master,
  ...
}:
{
  home.packages =
    with pkgs;
    (
      # -*- Data & Configuration Languages -*-#
      [
        #-- nix
        nil
        nixd
        statix # Lints and suggestions for the nix programming language
        deadnix # Find and remove unused code in .nix source files
        nixfmt # Nix Code Formatter

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
        dockerfile-language-server

        #-- markdown
        marksman # language server for markdown
        glow # markdown previewer
        pandoc # document converter
        pkgs-master.hugo # static site generator

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
          (python313.withPackages (
            ps: with ps; [
              # python language server
              pyright
              ruff

              pipx # Install and Run Python Applications in Isolated Environments
              black # python formatter
              uv # python project package manager

              # my commonly used python packages
              jupyter
              ipython
              pandas
              requests
              pyquery
              pyyaml
              boto3

              # misc
              protobuf # protocol buffer compiler
              numpy
            ]
          ))

          #-- rust
          # we'd better use the rust-overlays for rust development
          pkgs-master.rustc
          pkgs-master.rust-analyzer
          pkgs-master.cargo # rust package manager
          pkgs-master.rustfmt
          pkgs-master.clippy # rust linter

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
      # ++ [
      #   guile
      #   racket-minimal
      #   fnlfmt # fennel
      #   (
      #     if pkgs.stdenv.isLinux && pkgs.stdenv.isx86
      #     then pkgs-master.akkuPackages.scheme-langserver
      #     else pkgs.emptyDirectory
      #   )
      # ]
      ++ [
        proselint # English prose linter

        #-- verilog / systemverilog
        verible

        #-- Optional Requirements:
        nodePackages.prettier # common code formatter
        fzf
        gdu # disk usage analyzer, required by AstroNvim
        (ripgrep.override { withPCRE2 = true; }) # recursively searches directories for a regex pattern
      ]
    );
}

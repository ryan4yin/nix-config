{
  pkgs,
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

        #-- json like
        terraform-ls
        jsonnet
        jsonnet-language-server
        taplo # TOML language server / formatter / validator
        yaml-language-server
        actionlint # GitHub Actions linter

        #-- dockerfile
        hadolint # Dockerfile linter
        dockerfile-language-server

        #-- markdown
        marksman # language server for markdown
        pandoc # document converter
        hugo # static site generator

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

          #-- python
          uv # python project package manager
          (python313.withPackages (
            ps: with ps; [
              # python language server
              ty
              ruff

              # my commonly used python packages
              jupyter
              ipython
              pandas
              numpy
              requests
              pyquery
              pyyaml
              protobuf # protocol buffer compiler
            ]
          ))

          #-- rust
          # nixpkgs toolchain (cached); switch to rust-overlay if a pinned
          # toolchain or extra components are needed.
          rustc
          rust-analyzer
          cargo # rust package manager
          rustfmt
          clippy # rust linter

          #-- golang
          go
          gomodifytags
          iferr # generate error handling code for go
          impl # generate function implementation for go
          # gotools # contains tools like: godoc, goimports, etc.
          gopls # go language server
          delve # go debugger

          # -- java
          # jdk25
          # gradle
          # maven
          # spring-boot-cli
          # jdt-language-server

          #-- lua
          stylua
          lua-language-server

          #-- bash
          bash-language-server
          shellcheck
          shfmt
        ]
      #-*- Web Development -*-#
      ++ [
        nodejs_24
        pnpm
        typescript
        typescript-language-server
        bun
        # HTML/CSS/JSON/ESLint language servers extracted from vscode
        vscode-langservers-extracted
        tailwindcss-language-server
        emmet-ls
      ]
      ++ [
        proselint # English prose linter

        #-- Optional Requirements:
        prettier # common code formatter
        fzf
        ripgrep # recursively searches directories for a regex pattern
      ]
    );
}

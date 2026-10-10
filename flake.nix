{
  description = "Ryan Yin's nix configuration for both NixOS & macOS";

  ##################################################################################################################
  #
  # Want to know Nix in details? Looking for a beginner-friendly tutorial?
  # Check out https://github.com/ryan4yin/nixos-and-flakes-book !
  #
  ##################################################################################################################

  outputs = inputs: import ./outputs inputs;

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    # There are many ways to reference flake inputs. The most widely used is github:owner/name/reference,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    # Official NixOS package source, using nixos's unstable branch by default
    # Find git commit hash with build status here(3 jobs per day):
    # https://hydra.nixos.org/jobset/nixpkgs/unstable
    # update via nix flake update nixpkgs --override-input nixpkgs github:NixOS/nixpkgs/<commit-hash>
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Pinned to release tag v2.4.0 (not a branch); bump deliberately when needed.
    fcitx5-vinput = {
      url = "github:xifan2333/fcitx5-vinput/v2.4.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    # Kept for pinning a package that regressed in newer nixpkgs. Currently only
    # kubernetes-helm uses it (home/base/tui/container.nix); extend or drop this
    # input together with that consumer.
    nixpkgs-2505.url = "github:nixos/nixpkgs/nixos-25.05";

    # ryan4yin/nixpkgs fork for the `.agents/skills/nixpkgs-patched` workflow. It
    # currently carries no patches (see WORKAROUNDS.md), but `pkgs-patched` is
    # wired in outputs/default.nix so a temporary carry needs no flake edit.
    nixpkgs-patched.url = "github:ryan4yin/nixpkgs/nixos-unstable-patched";
    # get some latest packages from the master branch
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    # NixOS MicroVMs -- run the VMs directly on the hosts, replacing the former KubeVirt
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # for macos
    # nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/master";
      # url = "github:nix-community/home-manager/release-26.05";

      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/catppuccin/nix
    # main carries the rust-overlay-style deprecation fix for its vscode
    # package (nodejs -> nodejs-slim).
    catppuccin = {
      url = "github:catppuccin/nix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    # lanzaboote's pinned rust-overlay still uses the deprecated
    # `stdenv.isLinux`/`stdenv.isDarwin`; follow a newer revision.
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation = {
      url = "github:nix-community/preservation";
    };

    # Remote deployment via SSH. Pinned to the same v0.5.0 that nixpkgs ships
    # so the `colmenaHive` output we expose matches the CLI's schema.
    colmena = {
      url = "github:nix-community/colmena/v0.5.0";
      inputs.nixpkgs.follows = "nixpkgs";
      # Reuse the flake's own stable nixpkgs instead of colmena's pinned copy.
      inputs.stable.follows = "nixpkgs-stable";
    };

    # secrets management
    # Pinned to a release tag (not a branch) so `just up` cannot move it
    # silently; bump deliberately when a new release is needed.
    agenix = {
      url = "github:ryantm/agenix/0.18.0";
      # replaced with a type-safe reimplementation to get a better error message and less bugs.
      # url = "github:ryan4yin/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
      # Reuse the flake's own nix-darwin / home-manager instead of agenix's
      # pinned copies, collapsing duplicate lock nodes.
      inputs.darwin.follows = "nix-darwin";
      inputs.home-manager.follows = "home-manager";
    };

    disko = {
      url = "github:nix-community/disko/v1.13.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # add git hooks to format nix code before commit
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pinned nixpkgs for Blender (5.2 LTS + CUDA/OptiX).  Keeping it on a fixed
    # rev stops `just up` from re-bumping this input and triggering a full
    # Blender/CUDA source rebuild; bump the rev deliberately when needed.
    nixpkgs-blender.url = "github:nixos/nixpkgs/4b8338e3113dc41bcf7695f56dc372107b7ff4c9";

    nixos-apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # AI coding agents
    llm-agents.url = "github:numtide/llm-agents.nix";

    # -------------- Gaming ---------------------

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # x86/x86_64 emulation on 16K-page ARM64 (Apple Silicon). FEX cannot run
    # natively with 16K pages, so this wraps FEX in a 4K-page muvm microVM and
    # exposes an `x86pkgs` set plus Steam/Wine launchers. Used by shoukei; see
    # hosts/12kingdoms-shoukei and WORKAROUNDS.md (WA-021).
    #
    # Pinned to our fork of rowanG077/nix-x86-on-aarch64 at the reviewed commit
    # 5d69793a. To update, fetch upstream into the fork, review the new commits,
    # then bump the rev here deliberately. Do not track the fork's default branch:
    # a GitHub "Sync fork" fast-forward would pull unreviewed changes.
    nix-x86-on-aarch64 = {
      url = "github:ryan4yin/nix-x86-on-aarch64/5d69793a1c8b31d724fccd9b6acaa33587c923b3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ########################  Some non-flake repositories  #########################################

    nu_scripts = {
      url = "github:ryan4yin/nu_scripts";
      flake = false;
    };

    # Global agent skills, linked into ~/.agents/skills by
    # home/base/tui/agents/skills.nix. The ryan4yin forks track main; a fork sync
    # pulls upstream changes, so review the lock diff before deploying it.
    mattpocock-skills = {
      url = "github:ryan4yin/mattpocock-skills";
      flake = false;
    };
    i-have-adhd = {
      url = "github:ryan4yin/i-have-adhd";
      flake = false;
    };
    # Third-party skills pinned to a tag or commit; bump deliberately.
    humanizer = {
      url = "github:blader/humanizer/v3.1.0";
      flake = false;
    };
    ponytail = {
      url = "github:DietrichGebert/ponytail/v5.1.0";
      flake = false;
    };

    ########################  My own repositories  #########################################

    # my private secrets, it's a private repository, you need to replace it with your own.
    # use ssh protocol to authenticate via ssh-agent/ssh-key, and shallow clone to save time
    mysecrets = {
      url = "git+ssh://git@github.com/ryan4yin/nix-secrets.git?shallow=1";
      flake = false;
    };

    my-asahi-firmware = {
      url = "git+ssh://git@github.com/ryan4yin/asahi-firmware.git?shallow=1";
      flake = false;
    };

    # my wallpapers
    wallpapers = {
      url = "github:ryan4yin/wallpapers";
      flake = false;
    };

    # Personal NUR packages.
    nur-ryan4yin = {
      url = "github:ryan4yin/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Wayland <-> X11 clipboard sync daemon for xwayland-satellite (niri)
    pyclipsync = {
      url = "github:ryan4yin/pyclipsync/v0.1.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # terminal window manager / multiplexer; nixpkgs lags behind upstream,
    # so track the upstream flake.
    tuios = {
      url = "github:Gaurav-Gosain/tuios/v0.9.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}

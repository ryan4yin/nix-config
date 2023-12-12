{
  description = "NixOS & macOS configuration of Ryan Yin";

  ##################################################################################################################
  #
  # Want to know Nix in details? Looking for a beginner-friendly tutorial?
  # Check out https://github.com/ryan4yin/nixos-and-flakes-book !
  #
  ##################################################################################################################

  # The `outputs` function will return all the build results of the flake.
  # A flake can have many use cases and different types of outputs,
  # parameters in `outputs` are defined in `inputs` and can be referenced by their names.
  # However, `self` is an exception, this special parameter points to the `outputs` itself (self-reference)
  # The `@` syntax here is used to alias the attribute set of the inputs's parameter, making it convenient to use inside the function.
  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nix-darwin,
    home-manager,
    nixos-generators,
    nixos-licheepi4a,
    nixos-rk3588,
    ...
  }: let
    username = "ryan";
    userfullname = "Ryan Yin";
    useremail = "xiaoyin_c@qq.com";

    x64_system = "x86_64-linux";
    x64_darwin = "x86_64-darwin";
    riscv64_system = "riscv64-linux";
    aarch64_system = "aarch64-linux";
    allSystems = [x64_system x64_darwin riscv64_system aarch64_system];

    nixosSystem = import ./lib/nixosSystem.nix;
    macosSystem = import ./lib/macosSystem.nix;
    colmenaSystem = import ./lib/colmenaSystem.nix;

    # 星野 アイ, Hoshino Ai
    idol_ai_modules_i3 = {
      nixos-modules = [
        ./hosts/idols/ai
        ./modules/nixos/i3.nix
      ];
      home-module = import ./home/linux/desktop-i3.nix;
    };
    idol_ai_modules_hyprland = {
      nixos-modules = [
        ./hosts/idols/ai
        ./modules/nixos/hyprland.nix
      ];
      home-module = import ./home/linux/desktop-hyprland.nix;
    };

    # 星野 愛久愛海, Hoshino Akuamarin
    idol_aquamarine_modules = {
      nixos-modules = [
        ./hosts/idols/aquamarine
      ];
      home-module = import ./home/linux/server.nix;
    };
    idol_aquamarine_tags = ["dist-build" "aqua"];

    # 星野 瑠美衣, Hoshino Rubii
    idol_ruby_modules = {
      nixos-modules = [
        ./hosts/idols/ruby
      ];
      home-module = import ./home/linux/server.nix;
    };
    idol_ruby_tags = ["dist-build" "ruby"];

    # 有馬 かな, Arima Kana
    idol_kana_modules = {
      nixos-modules = [
        ./hosts/idols/kana
      ];
      home-module = import ./home/linux/server.nix;
    };
    idol_kana_tags = ["dist-build" "kana"];

    # 森友 望未, Moritomo Nozomi
    rolling_nozomi_modules = {
      nixos-modules = [
        ./hosts/rolling_girls/nozomi
      ];
      # home-module = import ./home/linux/server-riscv64.nix;
    };
    rolling_nozomi_tags = ["riscv" "nozomi"];

    # 小坂 結季奈, Kosaka Yukina
    rolling_yukina_modules = {
      nixos-modules = [
        ./hosts/rolling_girls/yukina
      ];
      # home-module = import ./home/linux/server-riscv64.nix;
    };
    rolling_yukina_tags = ["riscv" "yukina"];

    # 大木 鈴, Ōki Suzu
    _12kingdoms_suzu_modules = {
      nixos-modules = [
        ./hosts/12kingdoms/suzu
      ];
      # home-module = import ./home/linux/server.nix;
    };
    _12kingdoms_suzu_tags = ["aarch" "suzu"];

    x64_specialArgs =
      {
        inherit username userfullname useremail;
        # use unstable branch for some packages to get the latest updates
        pkgs-unstable = import nixpkgs-unstable {
          system = x64_system; # refer the `system` parameter form outer scope recursively
          # To use chrome, we need to allow the installation of non-free software
          config.allowUnfree = true;
        };
      }
      // inputs;
  in {
    nixosConfigurations = let
      base_args = {
        inherit home-manager nixos-generators;
        nixpkgs = nixpkgs; # or nixpkgs-unstable
        system = x64_system;
        specialArgs = x64_specialArgs;
      };
    in {
      # ai with i3 window manager
      ai_i3 = nixosSystem (idol_ai_modules_i3 // base_args);
      # ai with hyprland compositor
      ai_hyprland = nixosSystem (idol_ai_modules_hyprland // base_args);

      # three virtual machines without desktop environment.
      aquamarine = nixosSystem (idol_aquamarine_modules // base_args);
      ruby = nixosSystem (idol_ruby_modules // base_args);
      kana = nixosSystem (idol_kana_modules // base_args);
    };

    # colmena - remote deployment via SSH
    colmena = let
      # x86_64 related
      x64_base_args = {
        inherit home-manager;
        nixpkgs = nixpkgs; # or nixpkgs-unstable
        specialArgs = x64_specialArgs;
      };

      # riscv64 related
      # using the same nixpkgs as nixos-licheepi4a to utilize the cross-compilation cache.
      lpi4a_pkgs = import nixos-licheepi4a.inputs.nixpkgs {system = x64_system;};
      lpi4a_specialArgs =
        {
          inherit username userfullname useremail;
          pkgsKernel = nixos-licheepi4a.packages.${x64_system}.pkgsKernelCross;
        }
        // inputs;
      lpi4a_base_args = {
        inherit home-manager;
        nixpkgs = nixos-licheepi4a.inputs.nixpkgs; # or nixpkgs-unstable
        specialArgs = lpi4a_specialArgs;
        targetUser = "root";
      };

      # aarch64 related
      # using the same nixpkgs as nixos-rk3588 to utilize the cross-compilation cache.
      rk3588_pkgs = import nixos-rk3588.inputs.nixpkgs {system = x64_system;};
      rk3588_specialArgs =
        {
          inherit username userfullname useremail;
        }
        // nixos-rk3588.inputs;
      rk3588_base_args = {
        inherit home-manager;
        nixpkgs = nixos-rk3588.inputs.nixpkgs; # or nixpkgs-unstable
        specialArgs = rk3588_specialArgs;
        targetUser = "root";
      };
    in {
      meta = {
        nixpkgs = import nixpkgs {system = x64_system;};
        specialArgs = x64_specialArgs;

        nodeSpecialArgs = {
          # riscv64 SBCs
          nozomi = lpi4a_specialArgs;
          yukina = lpi4a_specialArgs;

          # aarch64 SBCs
          suzu = rk3588_specialArgs;
        };
        nodeNixpkgs = {
          nozomi = lpi4a_pkgs;
          yukina = lpi4a_pkgs;

          # aarch64 SBCs
          suzu = rk3588_pkgs;
        };
      };

      # proxmox virtual machines(x86_64)
      aquamarine = colmenaSystem (idol_aquamarine_modules // x64_base_args // {host_tags = idol_aquamarine_tags;});
      ruby = colmenaSystem (idol_ruby_modules // x64_base_args // {host_tags = idol_ruby_tags;});
      kana = colmenaSystem (idol_kana_modules // x64_base_args // {host_tags = idol_kana_tags;});

      # riscv64 SBCs
      nozomi = colmenaSystem (rolling_nozomi_modules // lpi4a_base_args // {host_tags = rolling_nozomi_tags;});
      yukina = colmenaSystem (rolling_yukina_modules // lpi4a_base_args // {host_tags = rolling_yukina_tags;});

      # aarch64 SBCs
      suzu = colmenaSystem (_12kingdoms_suzu_modules // rk3588_base_args // {host_tags = _12kingdoms_suzu_tags;});
    };

    # take system images for idols
    # https://github.com/nix-community/nixos-generators
    packages."${x64_system}" =
      # genAttrs returns an attribute set with the given keys and values(host => image).
      nixpkgs.lib.genAttrs [
        "ai_i3"
        "ai_hyprland"
      ] (
        # generate iso image for hosts with desktop environment
        host:
          self.nixosConfigurations.${host}.config.formats.iso
      )
      // nixpkgs.lib.genAttrs [
        "aquamarine"
        "ruby"
        "kana"
      ] (
        # generate proxmox image for virtual machines without desktop environment
        host:
          self.nixosConfigurations.${host}.config.formats.proxmox
      );

    # macOS's configuration, for work.
    darwinConfigurations = let
      system = x64_darwin;
      specialArgs =
        {
          inherit username userfullname useremail;
          # use unstable branch for some packages to get the latest updates
          pkgs-unstable = import nixpkgs-unstable {
            inherit system; # refer the `system` parameter form outer scope recursively
            # To use chrome, we need to allow the installation of non-free software
            config.allowUnfree = true;
          };
        }
        // inputs;
      base_args = {
        inherit nix-darwin home-manager system specialArgs nixpkgs;
      };
    in {
      harmonica = macosSystem (base_args
        // {
          darwin-modules = [
            ./hosts/harmonica
          ];
          home-module = import ./home/darwin;
        });
    };

    # format the nix code in this flake
    # alejandra is a nix formatter with a beautiful output
    formatter = nixpkgs.lib.genAttrs allSystems (
      system:
        nixpkgs.legacyPackages.${system}.alejandra
    );
  };

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    # There are many ways to reference flake inputs. The most widely used is github:owner/name/reference,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    # Official NixOS package source, using nixos's stable branch by default
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # for macos
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      # url = "github:nix-community/home-manager/master";

      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    # modern window compositor
    hyprland.url = "github:hyprwm/Hyprland/v0.32.3";
    # community wayland nixpkgs
    # nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    # anyrun - a wayland launcher
    anyrun = {
      url = "github:Kirottu/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # generate iso/qcow2/docker/... image from nixos configuration
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # secrets management, lock with git commit at 2023/7/15
    agenix.url = "github:ryantm/agenix/0d8c5325fc81daf00532e3e26c6752f7bcde1143";

    ########################  Some non-flake repositories  #########################################

    # AstroNvim is an aesthetic and feature-rich neovim config.
    astronvim = {
      url = "github:AstroNvim/AstroNvim/v3.39.0";
      flake = false;
    };

    # useful nushell scripts, such as auto_completion
    nushell-scripts = {
      url = "github:nushell/nu_scripts/main";
      flake = false;
    };

    ########################  My own repositories  #########################################

    # my private secrets, it's a private repository, you need to replace it with your own.
    # use ssh protocol to authenticate via ssh-agent/ssh-key, and shallow clone to save time
    mysecrets = {
      url = "git+ssh://git@github.com/ryan4yin/nix-secrets.git?shallow=1";
      flake = false;
    };

    # my wallpapers
    wallpapers = {
      url = "github:ryan4yin/wallpapers";
      flake = false;
    };

    nur-ryan4yin = {
      url = "github:ryan4yin/nur-packages";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    # riscv64 SBCs
    nixos-licheepi4a.url = "github:ryan4yin/nixos-licheepi4a";
    # nixos-jh7110.url = "github:ryan4yin/nixos-jh7110";

    # aarch64 SBCs
    nixos-rk3588.url = "github:ryan4yin/nixos-rk3588";

    ########################  Color Schemes  #########################################

    # color scheme - catppuccin
    catppuccin-btop = {
      url = "github:catppuccin/btop";
      flake = false;
    };
    catppuccin-fcitx5 = {
      url = "github:catppuccin/fcitx5";
      flake = false;
    };
    catppuccin-bat = {
      url = "github:catppuccin/bat";
      flake = false;
    };
    catppuccin-alacritty = {
      url = "github:catppuccin/alacritty";
      flake = false;
    };
    catppuccin-helix = {
      url = "github:catppuccin/helix";
      flake = false;
    };
    catppuccin-starship = {
      url = "github:catppuccin/starship";
      flake = false;
    };
    catppuccin-hyprland = {
      url = "github:catppuccin/hyprland";
      flake = false;
    };
    catppuccin-cava = {
      url = "github:catppuccin/cava";
      flake = false;
    };
    cattppuccin-k9s = {
      url = "github:catppuccin/k9s";
      flake = false;
    };
  };

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    # substituers will be appended to the default substituters when fetching packages
    extra-substituters = [
      "https://nix-community.cachix.org"
      # my own cache server
      "https://ryan4yin.cachix.org"
      "https://anyrun.cachix.org"
      "https://hyprland.cachix.org"
      # "https://nixpkgs-wayland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "ryan4yin.cachix.org-1:Gbk27ZU5AYpGS9i3ssoLlwdvMIh0NxG0w8it/cv9kbU="
      "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      # "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };
}

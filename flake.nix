{
  description = "NixOS & macOS configuration of Ryan Yin";

  ##################################################################################################################
  #
  # Want to know Nix in details? Looking for a beginner-friendly tutorial?
  # Check out https://github.com/ryan4yin/nixos-and-flakes-book !
  #
  ##################################################################################################################

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    experimental-features = ["nix-command" "flakes"];

    substituters = [
      # replace official cache with a mirror located in China
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];

    # nix community's cache server
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    # There are many ways to reference flake inputs. The most widely used is github:owner/name/reference,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    # Official NixOS package source, using nixos's stable branch by default
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # for macos
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-23.05-darwin";
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # modern window compositor
    hyprland.url = "github:hyprwm/Hyprland/v0.27.2";
    # community wayland nixpkgs
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";

    # generate iso/qcow2/docker/... image from nixos configuration
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # secrets management, lock with git commit at 2023/7/15
    agenix.url = "github:ryantm/agenix/0d8c5325fc81daf00532e3e26c6752f7bcde1143";

    # AstroNvim is an aesthetic and feature-rich neovim config.
    astronvim = {
      url = "github:AstroNvim/AstroNvim/v3.34.0";
      flake = false;
    };

    # my private secrets, it's a private repository, you need to replace it with your own.
    # use ssh protocol to authenticate via ssh-agent/ssh-key, and shallow clone to save time
    mysecrets = {
      url = "git+ssh://git@github.com/ryan4yin/nix-secrets.git?shallow=1";
      flake = false;
    };
  };

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
    ...
  }: let
    username = "ryan";
    userfullname = "Ryan Yin";
    useremail = "xiaoyin_c@qq.com";

    x64_system = "x86_64-linux";
    x64_darwin = "x86_64-darwin";
    allSystems = [x64_system x64_darwin];

    nixosSystem = import ./lib/nixosSystem.nix;
    macosSystem = import ./lib/macosSystem.nix;
  in {
    nixosConfigurations = let
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

      # 星野 瑠美衣, Hoshino Rubii
      idol_ruby_modules = {
        nixos-modules = [
          ./hosts/idols/ruby
        ];
        home-module = import ./home/linux/server.nix;
      };

      # 有馬 かな, Arima Kana
      idol_kana_modules = {
        nixos-modules = [
          ./hosts/idols/kana
        ];
        home-module = import ./home/linux/server.nix;
      };

      system = x64_system;
      specialArgs =
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
      base_args = {
        inherit home-manager nixos-generators system specialArgs;
      };
      stable_args = base_args // {inherit nixpkgs;};
      unstable_args = base_args // {nixpkgs = nixpkgs-unstable;};
    in {
      # ai with i3 window manager
      ai_i3 = nixosSystem (idol_ai_modules_i3 // stable_args);
      # ai with hyprland compositor
      ai_hyprland = nixosSystem (idol_ai_modules_hyprland // stable_args);

      aquamarine = nixosSystem (idol_aquamarine_modules // stable_args);
      ruby = nixosSystem (idol_ruby_modules // stable_args);
      kana = nixosSystem (idol_kana_modules // stable_args);
    };

    # take system images for idols
    # https://github.com/nix-community/nixos-generators
    packages."${x64_system}" =
      # genAttrs returns an attribute set with the given keys and values(host => image).
      nixpkgs.lib.genAttrs [
        "ai_i3"
        "ai_hyprland"
      ] (
        host:
          self.nixosConfigurations.${host}.config.formats.iso
      )
      // nixpkgs.lib.genAttrs [
        "aquamarine"
        "ruby"
        "kana"
      ] (
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
        inherit nix-darwin home-manager system specialArgs;
      };
    in {
      harmonica = macosSystem (base_args // {
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
}

{
  description = "NixOS configuration of Ryan Yin";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];

    substituters = [
      # replace official cache with a mirror located in China
      "https://mirrors.bfsu.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];

    # nix community's cache server
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://xddxdd.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "xddxdd.cachix.org-1:ay1HJyNDYmlSwj5NXQG065C8LfoqqKaTNCyzeixGjf8=" 
    ];
  };


  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # and `outputs` function will return all the build results of the flake. 
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    # There are many ways to reference flake inputs. The most widely used is github:owner/name/reference,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    # Official NixOS package source, using nixos-unstable branch here
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";
    
    # for macos
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-23.05-darwin";
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # nix users repository
    # used to install some packages not in nixpkgs
    # e.g. wechat-uos/qqmusic/dingtalk
    nur.url = "github:nix-community/NUR";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # modern window compositor
    hyprland.url = "github:hyprwm/Hyprland/v0.25.0";
    # community wayland nixpkgs
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";

    # generate iso/qcow2/docker/... image from nixos configuration
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # use devenv to manage my development environment
    devenv.url = "github:cachix/devenv/v0.6.2";
    
    # secrets management, lock with git commit at 2023/5/15
    agenix.url = "github:ryantm/agenix/db5637d10f797bb251b94ef9040b237f4702cde3";

    # nix language server, used by vscode & neovim
    nil.url = "github:oxalica/nil/2023-05-09";
  };

  # `outputs` are all the build result of the flake. 
  # A flake can have many use cases and different types of outputs.
  # parameters in `outputs` are defined in `inputs` and can be referenced by their names. 
  # However, `self` is an exception, This special parameter points to the `outputs` itself (self-reference)
  # The `@` syntax here is used to alias the attribute set of the inputs's parameter, making it convenient to use inside the function.
  outputs = inputs@{
      self,
      nixpkgs,
      darwin,
      home-manager,
      ...
  }: {
    nixosConfigurations = {
      # By default, NixOS will try to refer the nixosConfiguration with its hostname.
      # so the system named `msi-rtx4090` will use this configuration.
      # However, the configuration name can also be specified using `sudo nixos-rebuild switch --flake /path/to/flakes/directory#<name>`.
      # The `nixpkgs.lib.nixosSystem` function is used to build this configuration, the following attribute set is its parameter.
      # Run `sudo nixos-rebuild switch --flake .#msi-rtx4090` in the flake's directory to deploy this configuration on any NixOS system
      msi-rtx4090 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";

        # The Nix module system can modularize configurations, improving the maintainability of configurations.
        #
        # Each parameter in the `modules` is a Nix Module, and there is a partial introduction to it in the nixpkgs manual:
        #    <https://nixos.org/manual/nixpkgs/unstable/#module-system-introduction>
        # It is said to be partial because the documentation is not complete, only some simple introductions
        #    (such is the current state of Nix documentation...)
        # A Nix Module can be an attribute set, or a function that returns an attribute set.
        # If a Module is a function, according to the Nix Wiki description, this function can have up to four parameters:
        # 
        #   config: The configuration of the entire system
        #   options: All option declarations refined with all definition and declaration references.
        #   pkgs: The attribute set extracted from the Nix package collection and enhanced with the nixpkgs.config option.
        #   modulesPath: The location of the module directory of Nix.
        #
        # Only these four parameters can be passed by default.
        # If you need to pass other parameters, you must use `specialArgs` by uncomment the following line
        specialArgs = {
          inherit inputs;
          pkgs-stable = import inputs.nixpkgs-stable {
            system = system;  # refer the `system` parameter form outer scope recursively
            # To use chrome, we need to allow the installation of non-free software
            config.allowUnfree = true;
          };
        };
        modules = [
          ./hosts/msi-rtx4090

          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # pass all inputs into home manager's all sub modules
            home-manager.extraSpecialArgs = inputs;
            home-manager.users.ryan = import ./home/linux/x11.nix;
          }
        ];
      };

      nixos-test = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs; 
        modules = [
          ./hosts/nixos-test

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = inputs;
            home-manager.users.ryan = import ./home/linux/wayland.nix;
          }
        ];
      };
    };

    # configurations for MacOS
    darwinConfigurations."harmonica" = darwin.lib.darwinSystem {
      system = "x86_64-darwin";

      specialArgs = inputs; 
      modules = [
        ./hosts/harmonica

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          
          home-manager.extraSpecialArgs = inputs;
          home-manager.users.admin = import ./home/darwin;
        }
      ];
    };

    # generate qcow2 & iso image from nixos configuration
    #   https://github.com/nix-community/nixos-generators
    # packages.x86_64-linux = {
    #   qcow2 = nixos-generators.nixosGenerate {
    #     system = "x86_64-linux";
    #     modules = [
    #       # you can include your own nixos configuration here, i.e.
    #       # ./configuration.nix
    #     ];
    #     format = "qcow";
        
    #     # you can also define your own custom formats
    #     # customFormats = { "myFormat" = <myFormatModule>; ... };
    #     # format = "myFormat";
    #   };

    #   iso = nixos-generators.nixosGenerate {
    #     system = "x86_64-linux";
    #     modules = [
    #       # you can include your own nixos configuration here, i.e.
    #       # ./configuration.nix
    #     ];
    #     format = "iso";
    #   };
    # };
  };
}

{
  description = "NixOS configuration of Ryan Yin";

  # flake 为了确保够纯，它不依赖系统自身的 /etc/nix/nix.conf，而是在 flake.nix 中通过 nixConfig 设置
  # 但是为了确保安全性，flake 默认仅允许直接设置少数 nixConfig 参数，其他参数都需要在执行 nix 命令时指定 `--accept-flake-config`，否则会被忽略
  # <https://nixos.org/manual/nix/stable/command-ref/conf-file.html>
  # 如果有些包国内镜像下载不到，它仍然会走国外，这时候就得靠旁路由来解决了。
  # 临时修改默认网关为旁路由:  sudo ip route add default via 192.168.5.201
  #                        sudo ip route del default via 192.168.5.201
  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      # replace official cache with a mirror located in China
      "https://mirrors.bfsu.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
    ];

    # nix community's cache server
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      # "https://nixos-cn.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      # "nixos-cn.cachix.org-1:L0jEaL6w7kwQOPlLoCR3ADx+E3Q8SEFEcB9Jaibl0Xg="
    ];
  };

  # 这是 flake.nix 的标准格式，inputs 是 flake 的依赖，outputs 是 flake 的输出
  # inputs 中的每一项都被拉取、构建后，被作为参数传递给 outputs 函数
  inputs = {
    # flake inputs 有很多种引用方式，应用最广泛的是 github 的引用方式

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";       # 使用 nixos-unstable 分支 for nix flakes
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.11";    # unstable branch may be broken sometimes, use stable branch when necessary

    home-manager.url = "github:nix-community/home-manager";
    #　follows 是　inputs 中的继承语法
    # 这里使　home-manager 的　nixpkgs 这个 inputs 与当前　flake 的　inputs.nixpkgs 保持一致，避免依赖的　nixpkgs 版本不一致导致问题
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # modern window compositor
    hyprland.url = "github:hyprwm/Hyprland";
    # community wayland nixpkgs
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";

    # # nixos-cn 提供了一些国内常用的程序包，如 qq wechat dingtalk 等
    # nixos-cn = {
    #   url = "github:nixos-cn/flakes";
    #   # 强制 nixos-cn 和该 flake 使用相同版本的 nixpkgs
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  # outputs 的参数都是 inputs 中定义的依赖项，可以通过它们的名称来引用。
  # 不过 self 是个例外，这个特殊参数指向 outputs 自身（自引用），以及 flake 根目录
  # 这里的 @ 语法将函数的参数 attribute set 取了个别名，方便在内部使用
  outputs = inputs@{
      self,
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      # nixos-cn,
      ...
  }: {
    # 名为 nixosConfigurations 的 outputs 会在执行 `nixos-rebuild switch --flake .` 时被使用
    # 默认情况下会使用与主机 hostname 同名的 nixosConfigurations，但是也可以通过 `--flake .#<name>` 来指定
    nixosConfigurations = {
      # hostname 为 nixos-test 的主机会使用这个配置
      # 这里使用了 nixpkgs.lib.nixosSystem 函数来构建配置，后面的 attributes set 是它的参数
      # 在 nixos 上使用此命令部署配置：`nixos-rebuild switch --flake .#nixos-test`
      nixos-test = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        # modules 中每个参数，都是一个 NixOS Module <https://nixos.org/manual/nixos/stable/index.html#sec-modularity>
        # NixOS Module 可以是一个 attribute set，也可以是一个返回 attribute set 的函数
        # 如果是函数，那么它的参数就是当前的 NixOS Module 的参数.
        # 根据 Nix Wiki 对 NixOS modules 的描述，NixOS modules 函数的参数可以有这四个（详见本仓库中的 modules 文件）：
        #
        #  config: The configuration of the entire system
        #  options: All option declarations refined with all definition and declaration references.
        #  pkgs: The attribute set extracted from the Nix package collection and enhanced with the nixpkgs.config option.
        #  modulesPath: The location of the module directory of NixOS.
        #
        # nix flake 的 modules 系统可将配置模块化，提升配置的可维护性
        # 默认只能传上面这四个参数，如果需要传其他参数，必须使用 specialArgs
        specialArgs = {
          # inherit nixos-cn;
          inherit nixpkgs-stable;
        }; 
        modules = [
          ./hosts/nixos-test

          # home-manager 作为 nixos 的一个 module
          # 这样在 nixos-rebuild switch 时，home-manager 也会被自动部署，不需要额外执行 home-manager switch 命令
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # 使用 home-manager.extraSpecialArgs 自定义传递给 ./home 的参数
            home-manager.extraSpecialArgs = inputs;
            home-manager.users.ryan = import ./home;
          }

          ({pkgs, config, ... }: {
            config = {
              # use it as an overlay
              nixpkgs.overlays = [ 
                inputs.nixpkgs-wayland.overlay
              ];
            };
          })
        ];
      };

      msi-rtx4090 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {
          # inherit nixos-cn;
          inherit nixpkgs-stable;
        }; 
        modules = [
          ./hosts/msi-rtx4090

          # home-manager 作为 nixos 的一个 module
          # 这样在 nixos-rebuild switch 时，home-manager 也会被自动部署，不需要额外执行 home-manager switch 命令
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # 使用 home-manager.extraSpecialArgs 自定义传递给 ./home 的参数
            home-manager.extraSpecialArgs = inputs;
            home-manager.users.ryan = import ./home;
          }
        ];
      };


      # 如果你在 x86_64-linux 平台上执行 nix build，那么默认会使用这个配置，或者也能通过 `.#<name>` 参数来指定非 default 的配置
      # packages.x86_64-linux.default =
    };
  };
}

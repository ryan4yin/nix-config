{
  pkgs,
  config,
  nixos-cn,
  ...
}:
{
  imports = [
    # 将 nixos-cn flake 提供的 registry 添加到全局 registry 列表中
    # 可在`nixos-rebuild switch`之后通过`nix registry list`查看
    nixos-cn.nixosModules.nixos-cn-registries

    # 引入nixos-cn flake提供的NixOS模块
    nixos-cn.nixosModules.nixos-cn
  ];

  # # 使用 nixos-cn flake 提供的包
  home.packages = with nixos-cn.legacyPackages.${pkgs.system}; [
      # qq
      # wechat-uos           # TODO failed to install
      netease-cloud-music  # TODO chinese font missing
    ];
}
{
  pkgs,
  config,
  ...
}:
{
  nix.settings = {
    # enable flakes globally
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # NOTE: the normal user is deliberately NOT a trusted-user. That would
    # grant the right to inject arbitrary substituters (via `nixConfig` in a
    # flake, or `--option substituters ...`), which is a known root-equivalent
    # vector through the daemon. The flake's own `extra-substituters`
    # (cache.numtide.com) is instead listed in the system substituters below,
    # which the daemon applies for every user.

    # substituers that will be considered before the official ones(https://cache.nixos.org)
    substituters = [
      # cache mirror located in China
      # status: https://mirrors.ustc.edu.cn/status/
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      # status: https://mirror.sjtu.edu.cn/
      # "https://mirror.sjtu.edu.cn/nix-channels/store"
      # others
      # "https://mirrors.sustech.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"

      "https://nix-community.cachix.org"
      "https://catppuccin.cachix.org"
      # the cache used by the flake's own nixConfig (see flake.nix)
      "https://cache.numtide.com"
      # my own cache server, currently not used.
      # "https://ryan4yin.cachix.org"
    ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "ryan4yin.cachix.org-1:Gbk27ZU5AYpGS9i3ssoLlwdvMIh0NxG0w8it/cv9kbU="
    ];
    builders-use-substitutes = true;
  };
}

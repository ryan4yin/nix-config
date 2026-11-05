{
  pkgs,
  config,
  nixpkgsConfig,
  ...
}:
{
  nixpkgs.config = nixpkgsConfig;

  nix.settings = {
    # enable flakes globally
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # NOTE: the normal user is deliberately NOT a trusted-user. That would
    # grant the right to inject arbitrary substituters (via `nixConfig` in a
    # flake, or `--option substituters ...`), which is a known root-equivalent
    # vector through the daemon. Every substituter we want is instead listed in
    # the system substituters below, which the daemon applies for every user.

    # WARNING: `substituters` + `trusted-public-keys` are a security boundary,
    # not a convenience list. Nix downloads prebuilt store paths from a
    # substituter, and a trusted key means "trust anything signed by it" —
    # together they let a cache inject arbitrary store paths into your system,
    # which are then run as root at activation. Only add caches you fully trust.
    # The official https://cache.nixos.org is always trusted and is appended
    # automatically, so it does not need to be listed here.
    substituters = [
      # Domestic mirrors are fast from the LAN; query them directly first.
      # status: https://mirrors.ustc.edu.cn/status/
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      # status: https://mirror.sjtu.edu.cn/
      # "https://mirror.sjtu.edu.cn/nix-channels/store"
      # others
      # "https://mirrors.sustech.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"

      # Pull-through cache for upstreams that are slow from the LAN. Nix
      # appends the official cache.nixos.org last, so list its proxy here.
      "https://nix-cache.writefor.fun/cache.nixos.org"
      # numtide's cache (niks3), which serves the prebuilt packages of the
      # numtide/llm-agents.nix flake input used for the AI agent CLIs.
      "https://nix-cache.writefor.fun/cache.numtide.com"
      # Direct fallback if the LAN proxy is unavailable.
      "https://cache.numtide.com"

      # My own NUR cache, built by the ryan4yin/nur-packages CI. NUR's npm
      # dep hashes assume no registry mirror, so take them from the cache.
      "https://ryan4yin.cachix.org"
    ];

    # WARNING: every key here trusts *everything* that key signs. Add one only
    # for a cache you trust as much as the official one — a careless key hands
    # a third party the ability to ship you arbitrary store paths.
    trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      # ryan4yin.cachix.org, see substituters above.
      "ryan4yin.cachix.org-1:Gbk27ZU5AYpGS9i3ssoLlwdvMIh0NxG0w8it/cv9kbU="
    ];
    builders-use-substitutes = true;
  };
}

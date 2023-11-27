{pkgs, ...}: {
  ##########################################################################
  #
  #  Install all apps and packages here.
  #
  #  NOTE: Your can find all available options in:
  #    https://daiderd.com/nix-darwin/manual/index.html
  #
  # TODO Fell free to modify this file to fit your needs.
  #
  ##########################################################################

  # Install packages from nix's official package repository.
  #
  # The packages installed here are available to all users, and are reproducible across machines, and are rollbackable.
  # But on macOS, it's less stable than homebrew.
  #
  # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  environment.systemPackages = with pkgs; [
    neovim
    git
    nushell # my custom shell
    gnugrep  # replacee macos's grep
    gnutar # replacee macos's tar
  ];
  environment.variables.EDITOR = "nvim";

  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;
  environment.shells = [
    pkgs.zsh
    pkgs.nushell # my custom shell
  ];

  # Homebrew Mirror
  environment.variables = {
    HOMEBREW_API_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api";
    HOMEBREW_BOTTLE_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles";
    HOMEBREW_BREW_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git";
    HOMEBREW_CORE_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git";
    HOMEBREW_PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";
  };

  # homebrew need to be installed manually, see https://brew.sh
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
      cleanup = "zap";
    };

    # Applications to install from Mac App Store using mas.
    # You need to install all these Apps manually first so that your apple account have records for them.
    # otherwise Apple Store will refuse to install them.
    # For details, see https://github.com/mas-cli/mas
    masApps = {
      # Xcode = 497799835;
      Wechat = 836500024;
      QQ = 451108668;
      WeCom = 1189898970; # Wechat for Work
      TecentMetting = 1484048379;
      NeteaseCloudMusic = 944848654;
      QQMusic = 595615424;
    };

    taps = [
      "homebrew/cask"
      "homebrew/cask-fonts"
      "homebrew/services"
      "homebrew/cask-versions"

      "hashicorp/tap"
      "pulumi/tap"
    ];

    brews = [
      # `brew install`
      "wget" # download tool
      "curl" # no not install curl via nixpkgs, it's not working well on macOS!
      "aria2" # download tool
      "httpie" # http client
      "wireguard-tools" # wireguard
      "mitmproxy"

      # Usage:
      #  https://github.com/tailscale/tailscale/wiki/Tailscaled-on-macOS#run-the-tailscaled-daemon
      # 1. `sudo tailscaled install-system-daemon`
      # 2. `tailscale up --accept-routes`
      "tailscale" # tailscale

      # https://github.com/rgcr/m-cli
      "m-cli" #  Swiss Army Knife for macOS
      "proxychains-ng"

      # commands like `gsed` `gtar` are required by some tools
      "gnu-sed"
      "gnu-tar"

      # misc that nix do not have cache for.
      "git-trim"
      "terraform"
      "terraformer"
    ];

    # `brew install --cask`
    casks = [
      "wezterm"

      "squirrel" # input method for Chinese, rime-squirrel

      "firefox"
      "google-chrome"
      "visual-studio-code"

      # IM & audio & remote desktop & meeting
      "telegram"
      "discord"
      "neteasemusic"
      "qqmusic"
      "microsoft-remote-desktop"

      # "anki"
      "clashx" # proxy tool
      "iina" # video player
      "openinterminal-lite" # open current folder in terminal
      "syncthing" # file sync
      "raycast" # (HotKey: alt/option + space)search, caculate and run scripts(with many plugins)
      "iglance" # beautiful system monitor
      "eudic" # 欧路词典
      # "reaper"  # audio editor
      "sonic-pi" # music programming

      # Development
      "insomnia" # REST client
      "wireshark" # network analyzer
      "temurin17"  # JDK 17
      "jdk-mission-control" # Java Mission Control
      "google-cloud-sdk" # Google Cloud SDK
    ];
  };
}

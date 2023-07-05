{ pkgs, ...}: {

  ##########################################################################
  # 
  #  MacOS specific nix-darwin configuration
  #
  #  Nix is not well supported on macOS, I met some strange bug recently.
  #  So install apps using [homebrew](https://daiderd.com/nix-darwin/manual/index.html#opt-homebrew.enable) here.
  # 
  ##########################################################################

  system = {
    defaults = {
      dock = {
        autohide = true;
      };

      finder = {
        _FXShowPosixPathInTitle = false;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
      cleanup = "zap";
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
      "httpie"
      "wireguard-tools"
    ];

    # `brew install --cask`
    casks = [
      "firefox"
      "google-chrome"
      "visual-studio-code"
      "visual-studio-code-insiders"

      "telegram"
      "discord"
      "wechat"
      "qq"
      "neteasemusic"
      "qqmusic"
      "microsoft-remote-desktop"
      "wechatwork"
      "tencent-meeting"

      # "anki"
      "clashx"
      "iina"
      "openinterminal-lite"
      "syncthing"
      "raycast"
      "iglance"
      "eudic"
      "baiduinput"  # baidu input method
      # "reaper"

      "insomnia"
      "wireshark"
      "jdk-mission-control"
      "google-cloud-sdk"
    ];
  };
}
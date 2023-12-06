{
  pkgs,
  catppuccin-cava,
  pkgs-unstable,
  ...
}:
# media - control and enjoy audio/video
{
  home.packages = with pkgs; [
    # audio control
    pavucontrol
    playerctl
    pulsemixer
    imv # simple image viewer

    nvtop

    # video/audio tools
    cava # for visualizing audio
    libva-utils
    vdpauinfo
    vulkan-tools
    glxinfo
  ];

  # https://github.com/catppuccin/cava
  home.file.".config/cava/config".text = ''
    # custom cava config
  '' + builtins.readFile "${catppuccin-cava}/mocha.cava";

  programs = {
    mpv = {
      enable = true;
      defaultProfiles = ["gpu-hq"];
      scripts = [pkgs.mpvScripts.mpris];
    };

    # terminal file manager
    yazi = {
      enable = true;
      package = pkgs-unstable.yazi;
      enableBashIntegration = true;
      # TODO: nushellIntegration is broken on release-23.11, wait for master's fix to be released
      enableNushellIntegration = false;
    };
  };

  services = {
    playerctld.enable = true;
  };
}

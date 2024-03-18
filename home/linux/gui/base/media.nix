{
  pkgs,
  pkgs-unstable,
  nur-ryan4yin,
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
  xdg.configFile."cava/config".text =
    ''
      # custom cava config
    ''
    + builtins.readFile "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-cava}/mocha.cava";

  programs = {
    mpv = {
      enable = true;
      defaultProfiles = ["gpu-hq"];
      scripts = [pkgs.mpvScripts.mpris];
    };
  };

  services = {
    playerctld.enable = true;
  };
}

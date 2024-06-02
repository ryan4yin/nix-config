{
  pkgs,
  pkgs-unstable,
  # pkgs-stable,
  nur-ryan4yin,
  ...
}: {
  home.packages = with pkgs; [
    # creative
    blender # 3d modeling
    # gimp      # image editing, I prefer using figma in browser instead of this one
    inkscape # vector graphics
    krita # digital painting
    musescore # music notation
    # reaper # audio production
    # sonic-pi # music programming

    # this app consumes a lot of storage, so do not install it currently
    # kicad     # 3d printing, eletrical engineering

    # fpga
    pkgs-unstable.python312Packages.apycula # gowin fpga
    pkgs-unstable.yosys # fpga synthesis
    pkgs-unstable.nextpnr # fpga place and route
    pkgs-unstable.openfpgaloader # fpga programming
    nur-ryan4yin.packages.${pkgs.system}.gowin-eda-edu-ide # app: `gowin-env` => `gw_ide` / `gw_pack` / ...
  ];

  programs = {
    # live streaming
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        # screen capture
        wlrobs
        # obs-ndi
        obs-vaapi
        obs-nvfbc
        obs-teleport
        # obs-hyperion
        droidcam-obs
        obs-vkcapture
        obs-gstreamer
        obs-3d-effect
        input-overlay
        obs-multi-rtmp
        obs-source-clone
        obs-shaderfilter
        obs-source-record
        obs-livesplit-one
        looking-glass-obs
        obs-vintage-filter
        obs-command-source
        obs-move-transition
        obs-backgroundremoval
        advanced-scene-switcher
        obs-pipewire-audio-capture
      ];
    };
  };
}

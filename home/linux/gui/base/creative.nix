{
  pkgs,
  pkgs-stable,
  pkgs-master,
  pkgs-blender,
  ...
}:
let
  bambu-studio = pkgs.symlinkJoin {
    name = "bambu-studio-${pkgs-master.bambu-studio.version}";
    paths = [ pkgs-master.bambu-studio ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      # Work around wxWidgets HiDPI text clipping under fractional scaling.
      # https://github.com/bambulab/BambuStudio/issues/4959
      wrapProgram $out/bin/bambu-studio --set GDK_DPI_SCALE 0.8
    '';
  };
in
{
  home.packages = with pkgs-stable; [
    # creative
    # gimp      # image editing, I prefer using figma in browser instead of this one
    krita # digital painting
    musescore # music notation
    pkgs-master.orca-slicer # 3d printer slicer app
    bambu-studio # bambu 3d printer slicer app
    pkgs-blender.blender # 3d modeling
    # reaper # audio production
    # sonic-pi # music programming

    # 2d game design
    # aseprite # Animated sprite editor & pixel art tool

    # this app consumes a lot of storage, so do not install it currently
    # kicad     # 3d printing, electrical engineering
  ];

  programs = {
    # live streaming
    obs-studio = {
      enable = pkgs.stdenv.hostPlatform.isx86_64;
      plugins = with pkgs.obs-studio-plugins; [
        # screen capture
        wlrobs
        # obs-ndi
        # obs-nvfbc
        # obs-teleport
        # obs-hyperion
        # droidcam-obs
        # obs-vkcapture
        obs-gstreamer
        input-overlay
        obs-multi-rtmp
        obs-source-clone
        # obs-shaderfilter
        # obs-source-record
        # obs-livesplit-one
        # looking-glass-obs
        # obs-vintage-filter
        # obs-command-source
        # obs-move-transition
        # obs-backgroundremoval
        # advanced-scene-switcher
        obs-pipewire-audio-capture
        obs-vaapi
        # obs-3d-effect
      ];
    };
  };
}

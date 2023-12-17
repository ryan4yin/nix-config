{
  pkgs,
  pkgs-unstable,
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
    pkgs-unstable.sonic-pi # music programming

    # this app consumes a lot of storage, so do not install it currently
    # kicad     # 3d printing, eletrical engineering

    # fpga
    pkgs-unstable.python311Packages.apycula # gowin fpga
    pkgs-unstable.yosys # fpga synthesis
    pkgs-unstable.nextpnr # fpga place and route
    pkgs-unstable.openfpgaloader # fpga programming
    nur-ryan4yin.packages.${pkgs.system}.gowin-eda-edu-ide # app: `gowin-env` => `gw_ide` / `gw_pack` / ...
  ];

  programs = {
    # live streaming
    obs-studio.enable = true;
  };
}

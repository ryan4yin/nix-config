{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    # use wayland version of firefox
    firefox-wayland
  ];

  programs = {
    let commandLineArgs = [ "--enable-wayland-ime" "--ozone-platform=wayland" ];
    in {
      chromium = {
        enable = true;
        inherit commandLineArgs;
      };
      google-chrome = {
        enable = true;
        inherit commandLineArgs;
      };
    };
  };
}
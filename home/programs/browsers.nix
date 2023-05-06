{
  pkgs,
  nixpkgs-stable,
  config,
  ...
}: {
  home.packages = 
    let
      pkgs-stable = import nixpkgs-stable {
        system = pkgs.system;
        config.allowUnfree = true;
      };
    in
    with pkgs-stable; [
      firefox-wayland

      # chrome wayland support was broken on nixos-unstable branch, so fallback to stable branch for now
      # https://github.com/swaywm/sway/issues/7562
      google-chrome
    ];

  # programs = {
  # };
}

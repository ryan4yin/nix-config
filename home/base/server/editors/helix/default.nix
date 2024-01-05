{pkgs, ...}: {
  programs.helix = {
    enable = true;
    package = pkgs.helix;
  };
}

{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    skopeo
    docker-compose
    dive # explore docker layers
   ];

  programs = {
  };
}

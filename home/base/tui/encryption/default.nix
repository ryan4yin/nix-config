{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    age
    sops
    rclone
  ];
}

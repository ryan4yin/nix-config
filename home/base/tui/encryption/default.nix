{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    age
    pkgs-unstable.sops
    rclone
  ];
}

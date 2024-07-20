{pkgs-stable, ...}: {
  home.packages = with pkgs-stable; [
    # https://joplinapp.org/help/
    joplin # joplin-cli
    joplin-desktop
  ];
}

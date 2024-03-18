{pkgs, ...}: {
  home.packages = with pkgs; [
    # https://joplinapp.org/help/
    joplin # joplin-cli
    joplin-desktop
  ];
}

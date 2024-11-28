{config, ...}: {
  home.file.".aerospace.toml".source =
    config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/nix-config/home/darwin/aerospace/aerospace.toml";
}

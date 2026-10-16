{
  config,
  lib,
  catppuccin,
  ...
}:
{
  # https://github.com/catppuccin/nix
  imports = [
    catppuccin.homeModules.catppuccin
  ];

  catppuccin = {
    # The default `enable` value for all available programs.
    enable = true;
    # Enroll every supported port (catppuccin/nix >= main behaviour).
    autoEnable = true;
    # Catppuccin's ports build locally, and the user-level cache entry this
    # adds to ~/.config/nix/nix.conf would be ignored (with a warning) now that
    # the normal user is not a trusted-user. See modules/base/nix.nix.
    cache.enable = false;
    # one of "latte", "frappe", "macchiato", "mocha"
    flavor = "mocha";
    # one of "blue", "flamingo", "green", "lavender", "maroon", "mauve", "peach", "pink", "red", "rosewater", "sapphire", "sky", "teal", "yellow"
    accent = "pink";
  };

  # catppuccin/nix reads some ports at eval time (the starship port via
  # `lib.importTOML "${sources.starship}/<flavor>.toml"`) and inlines the
  # result, so no store path in the generation references the built port. gc
  # then deletes it and the next deploy rebuilds it from scratch, alongside
  # catppuccin's build/install hooks and the fetched port source. Listing the
  # path here records it in the generation, which is a gc root. See WA-036.
  home.extraDependencies = lib.optional config.catppuccin.starship.enable config.catppuccin.sources.starship;
}

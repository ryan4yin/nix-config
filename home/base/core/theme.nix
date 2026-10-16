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

  # catppuccin/nix inlines the starship port at eval time, so nothing references
  # the build and gc drops it; this keeps it in the home closure. See WA-036.
  home.extraDependencies = lib.optional config.catppuccin.starship.enable config.catppuccin.sources.starship;
}

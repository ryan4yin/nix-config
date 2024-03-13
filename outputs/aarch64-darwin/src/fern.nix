{mylib, ...} @ args: let
  name = "fern";

  modules = {
    darwin-modules =
      (map mylib.relativeToRoot [
        # common
        "secrets/darwin.nix"
        "modules/darwin"
        # host specific
        "hosts/darwin-${name}"
      ])
      ++ [];
    home-modules = map mylib.relativeToRoot [
      "hosts/darwin-${name}/home.nix"
      "home/darwin"
    ];
  };

  systemArgs = modules // args;
in {
  # macOS's configuration
  darwinConfigurations.${name} = mylib.macosSystem systemArgs;
}

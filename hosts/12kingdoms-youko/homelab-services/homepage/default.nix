{ lib, ... }:
{
  services.homepage-dashboard = {
    enable = true;
    listenPort = 54401;
    allowedHosts = "home.writefor.fun";
  };

  # Keep the config as plain YAML instead of the module's Nix options.
  environment.etc = lib.listToAttrs (
    map (f: lib.nameValuePair "homepage-dashboard/${f}" { source = lib.mkForce ./${f}; }) [
      "bookmarks.yaml"
      "services.yaml"
      "settings.yaml"
      "widgets.yaml"
    ]
  );
}

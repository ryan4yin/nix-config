# Heroic Games Launcher sandbox for Epic, GOG and Amazon games. Heroic keeps its
# configuration in ~/.config/heroic and downloads its Wine/Proton/DXVK builds
# into ~/.config/heroic/tools, both inside ~/Gaming, and installs games under
# ~/Games (its default, the sandbox's view of ~/Gaming/Games). It launches them
# itself, so they inherit this sandbox.
{
  heroic,
  gamescope,
  mkNixPak,
  ...
}:
let
  appId = "com.heroicgameslauncher.hgl";
  package = heroic.override {
    extraPkgs = _: [ gamescope ];
  };
  wrapped = mkNixPak {
    config = {
      imports = [ ./modules/gaming-policy.nix ];
      app = {
        inherit package;
        binPath = "bin/heroic";
      };
      flatpak = { inherit appId; };
    };
  };
in
wrapped.config.script

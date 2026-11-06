# Heroic Games Launcher sandbox for Epic, GOG and Amazon games. Heroic keeps its
# configuration in ~/.config/heroic and downloads its Wine/Proton/DXVK builds
# into ~/.config/heroic/tools, both inside ~/Gaming, and installs games under
# ~/Games (its default, the sandbox's view of ~/Gaming/Games). It launches them
# itself, so they inherit this sandbox.
{
  lib,
  heroic,
  gamescope,
  # Heroic is Electron inside this FHS, so its CJK text needs these too.
  wqy_zenhei,
  noto-fonts-cjk-sans,
  buildEnv,
  runCommandLocal,
  mkNixPak,
  ...
}:
let
  appId = "com.heroicgameslauncher.hgl";
  package = heroic.override {
    extraPkgs = _: [
      gamescope
      wqy_zenhei
      noto-fonts-cjk-sans
    ];
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
  exe = lib.getExe wrapped.config.script;
  assets = runCommandLocal "heroic-desktop-assets" { } ''
    mkdir -p $out/share/applications
    substitute ${package}/share/applications/${appId}.desktop \
      $out/share/applications/${appId}.desktop \
      --replace-fail "Exec=heroic" "Exec=${exe}"
    cp -r ${package}/share/icons $out/share/icons
  '';
in
buildEnv {
  inherit (wrapped.config.script) name meta passthru;
  paths = [
    wrapped.config.script
    assets
  ];
}

# Steam sandbox. Steam starts its own pressure-vessel container inside this
# one, as umu does, so games stay inside ~/Gaming: the library, the compatdata
# prefixes and every Proton build live there. DW-Proton and GE-Proton come
# from modules/gaming-policy.nix. Remote Play and LAN transfers need inbound
# connections that pasta isolation does not forward.
{
  lib,
  steam,
  gamescope,
  mangohud,
  buildEnv,
  runCommandLocal,
  mkNixPak,
  ...
}:
let
  appId = "com.valvesoftware.Steam";
  package = steam.override {
    extraPkgs = _: [
      gamescope
      mangohud
    ];
  };
  wrapped = mkNixPak {
    config = {
      imports = [ ./modules/gaming-policy.nix ];
      app = {
        inherit package;
        binPath = "bin/steam";
      };
      flatpak = { inherit appId; };
    };
  };
  exe = lib.getExe wrapped.config.script;
  # The desktop entry and icons ship in the wrapped package; the nixpak script
  # has no share/ of its own, so point the entry at the script instead of the
  # unsandboxed binary.
  assets = runCommandLocal "steam-desktop-assets" { } ''
    mkdir -p $out/share/applications
    substitute ${package}/share/applications/steam.desktop \
      $out/share/applications/steam.desktop \
      --replace-fail "Exec=steam" "Exec=${exe}"
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

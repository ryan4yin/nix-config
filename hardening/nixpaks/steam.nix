# Steam sandbox. Steam starts its own pressure-vessel container inside this
# one, as umu does, so games stay inside ~/Gaming: the library, the compatdata
# prefixes and every Proton build live there. Remote Play and LAN transfers
# need inbound connections that pasta isolation does not forward.
{
  lib,
  steam,
  gamescope,
  mangohud,
  dwproton-bin,
  proton-ge-bin,
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
    # Each game's Properties -> Compatibility offers these. Both are store
    # paths, which the sandbox can read and a game cannot modify.
    extraEnv = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = lib.makeSearchPathOutput "steamcompattool" "" [
        dwproton-bin
        proton-ge-bin
      ];
    };
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
in
wrapped.config.script

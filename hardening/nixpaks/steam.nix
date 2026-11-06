# Steam sandbox. Steam starts its own pressure-vessel container inside this
# one, as umu does, so games stay inside ~/Gaming: the library, the compatdata
# prefixes and every Proton build live there. DW-Proton and GE-Proton come
# from modules/gaming-policy.nix. Remote Play and LAN transfers need inbound
# connections that pasta isolation does not forward.
{
  steam,
  gamescope,
  mangohud,
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
in
wrapped.config.script

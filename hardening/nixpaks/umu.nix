# umu-launcher sandbox for Windows games outside Steam. The launchers that the
# nix-config-umu-game skill writes to ~/Gaming/Games/<name> are game-writable,
# so the host never executes them: `umu-sandbox ~/Games/<name>/run` (a sandbox
# path) runs the whole script, conf and prelaunch included, inside the sandbox.
{
  steam,
  umu-launcher-unwrapped,
  mangohud,
  winetricks,
  bbe,
  gamescope,
  dwproton-bin,
  writeShellScript,
  mkNixPak,
  ...
}:
let
  appId = "org.openwinecomponents.umu";
  # pkgs/by-name/um/umu-launcher, with a generic entry point and the tools the
  # generated launchers call.
  package = steam.buildRuntimeEnv {
    pname = "umu-sandbox";
    inherit (umu-launcher-unwrapped) version;
    extraPkgs = _: [
      umu-launcher-unwrapped
      mangohud
      winetricks
      bbe
      gamescope
    ];
    executableName = "umu-sandbox";
    runScript = writeShellScript "umu-sandbox" ''exec "$@"'';
    # As upstream: Legendary spawns umu and exits without waiting for it.
    dieWithParent = false;
    meta = umu-launcher-unwrapped.meta // {
      mainProgram = "umu-sandbox";
    };
  };
  wrapped = mkNixPak {
    config = {
      imports = [ ./modules/gaming-policy.nix ];
      app = {
        inherit package;
        binPath = "bin/umu-sandbox";
      };
      flatpak = { inherit appId; };
      bubblewrap.env = {
        # The session's UMU_PROTONPATH does not survive clearEnv; this path
        # also tracks every dwproton-bin update.
        UMU_PROTONPATH = "${dwproton-bin.steamcompattool}";
        # Lets the generated launchers refuse to start outside the sandbox.
        UMU_SANDBOX = "1";
      };
    };
  };
in
wrapped.config.script

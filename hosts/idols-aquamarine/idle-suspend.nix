{
  myvars,
  pkgs,
  ...
}:
let
  idleMinutes = 60;
in
{
  # Request-scoped services hold an established TCP connection while they work.
  # This covers ASR, llama-swap/Strata, and MagPie without inspecting GPU state.
  services.autosuspend = {
    enable = true;
    # nixpkgs 11.3.0's test collection misses docutils; the package itself is fine.
    package =
      (pkgs.autosuspend.override {
        withDocs = false;
        withMan = false;
      }).overridePythonAttrs
        (_: {
          doCheck = false;
        });
    settings = {
      interval = 60;
      idle_time = idleMinutes * 60;
      suspend_cmd = "${pkgs.systemd}/bin/systemctl suspend";
    };
    checks = {
      Sessions = {
        class = "LogindSessionsIdle";
      };
      Load = {
        threshold = 1.0;
      };
      Asr = {
        class = "ActiveConnection";
        ports = toString myvars.ports.aquamarineAsr;
      };
      Inference = {
        class = "ActiveConnection";
        ports = "63081,63083,63084,65002";
      };
    };
  };
}

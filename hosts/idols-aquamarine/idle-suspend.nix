{
  myvars,
  pkgs,
  ...
}:
let
  idleMinutes = 60;
in
{
  services.autosuspend = {
    enable = true;
    # nixpkgs' pytest hook misses docutils for test_ext_autosuspend.py.
    package =
      (pkgs.autosuspend.override {
        withDocs = false;
        withMan = false;
      }).overridePythonAttrs
        (old: {
          nativeCheckInputs =
            (old.nativeCheckInputs or [ ])
            ++ (with pkgs.python3Packages; [
              sphinx
              docutils
            ]);
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
      # ASR listens on 18080.
      Asr = {
        class = "ActiveConnection";
        ports = toString myvars.ports.aquamarineAsr;
      };
      # llama-swap/Strata: 63081 is the proxy, 65002 the direct backend.
      Inference = {
        class = "ActiveConnection";
        ports = "63081,65002";
      };
      # MagPie API and web UI: 63083 and 63084.
      MagPie = {
        class = "ActiveConnection";
        ports = "63083,63084";
      };
    };
  };
}

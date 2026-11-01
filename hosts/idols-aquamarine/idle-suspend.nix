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
      # 63081: llama-swap/Strata; 63083/63084: MagPie; 65002: direct Strata.
      # These services hold an established connection while a request is active.
      Inference = {
        class = "ActiveConnection";
        ports = "63081,63083,63084,65002";
      };
    };
  };
}

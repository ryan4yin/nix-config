{
  lib,
  mylib,
  myvars,
  pkgs,
  pkgs-npu,
  ...
}:
let
  inherit (myvars.networking.hostsAddr.aquamarine) ipv4;
  port = 18080;

  # OpenVINO publishes static IRs for Whisper only, and the NPU compiler accepts
  # nothing less: any other ASR family keeps a dynamic time axis and aborts it
  # (WORKAROUNDS.md WA-037). Pinned by content because the NPU caches the
  # compiled graph; a version bump should be deliberate.
  modelFiles = {
    "added_tokens.json" = "sha256-PFH2bEwh+eEmlwB48RrnenjHSu6N9gbunauobkZxCOA=";
    "config.json" = "sha256-v9ksCXVHqxLLQquugAi+WlmpH9xas5rM4kSJ64o+ioY=";
    "generation_config.json" = "sha256-Rhf8ykWK87kaEDFDqqyRnBq2aAtVLXq9EIEbcki9d7Q=";
    "merges.txt" = "sha256-LfKZCjleNejfvHUR4IwS1WAY2NBGkeATPl1jsh4VTcY=";
    "normalizer.json" = "sha256-vxxQfchyTKnPmQNkDaz7adri8A7e5PIc66EGpzkvJt0=";
    "openvino_config.json" = "sha256-naOOiM7Aaa1UaZ1ifxxZ02w2o9+1S14btc/fWDLvrwM=";
    "openvino_decoder_model.bin" = "sha256-wGSZHLr8Q4FWfSmXK3AT3CQCbenDJtA+sebk/ESqlZ8=";
    "openvino_decoder_model.xml" = "sha256-rrCfr78cDL+EuvMPRnY0NgBYIvrzs2U1m43gqgTwMEc=";
    "openvino_detokenizer.bin" = "sha256-8rPEeCWhCJUl/2XAyOSSceHe5ppAGgT8gnrC3lt3ZuQ=";
    "openvino_detokenizer.xml" = "sha256-bhBqFPFLB3G0a3lIqZsdgZ/5OyRVt9qPR3Yaudup3FY=";
    "openvino_encoder_model.bin" = "sha256-BZCo81+W1XgBxVmQAo2ReCGschAm40t/P1nXVh/JCOY=";
    "openvino_encoder_model.xml" = "sha256-YHE9TtOorI7gIOEcRzfsJ20UyrxqCCU3vd8sALps4HA=";
    "openvino_tokenizer.bin" = "sha256-rfo9mikg0PMUEhJwqWCrMx7A8Fg4VEu47KqkIigqb9Q=";
    "openvino_tokenizer.xml" = "sha256-y6ME57rVR3O50svM+8hQERfs8uPA9PUzF0Kgo8n+7ZM=";
    "preprocessor_config.json" = "sha256-ZUzxjT4WO5SM6vl2baVs4LUt4mXVhnPPYck3bxJr1Jk=";
    "special_tokens_map.json" = "sha256-uupOoJNy60/KhrTkNGE5/XPLgH1Qh+neCUjpcXOcPnQ=";
    "tokenizer_config.json" = "sha256-PHWUDfzjopT8pwQaX6/wEWd/G2j6heR1EbuM9tzK3tY=";
    "tokenizer.json" = "sha256-XBvzDJ5xbhR3vt74RrAb4AE9rsuJ6ePveribI8F43xs=";
    "vocab.json" = "sha256-Z4jICwgumw0TkxR9Oj5iuhkoWsDIKs6OXvAPN+rViXE=";
  };

  whisperModel = pkgs.runCommandLocal "whisper-large-v3-turbo-int8-ov" { } ''
    mkdir -p $out
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: hash: ''
        ln -s ${
          pkgs.fetchurl {
            url = "https://huggingface.co/OpenVINO/whisper-large-v3-turbo-int8-ov/resolve/main/${name}";
            inherit hash;
          }
        } $out/${name}
      '') modelFiles
    )}
  '';

  # openvino-genai 2026.4.0.0 fails to compile against the OpenVINO headers in
  # nixos-unstable (no matching constructor in continuous_batching); the branch's
  # nixpkgs builds it, and the service has to match the NPU stack anyway.
  pythonEnv = pkgs-npu.python3.withPackages (ps: [
    ps.fastapi
    ps.numpy
    ps.openvino-genai
    # FastAPI's form/file parsing is not part of fastapi itself.
    ps.python-multipart
    ps.uvicorn
  ]);
in
{
  # vinput on the desktop sends raw PCM here and gets text back; the endpoint is
  # the OpenAI transcription API, so any client of that shape works.
  systemd.services.whisper-asr = {
    description = "OpenAI-compatible Whisper transcription service (Intel NPU)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    environment = {
      WHISPER_MODEL_DIR = "${whisperModel}";
      WHISPER_MODEL_NAME = "whisper-large-v3-turbo";
      WHISPER_DEVICE = "NPU";
      WHISPER_HOST = ipv4;
      WHISPER_PORT = toString port;
      # Compiling the graph for the NPU takes ~70 s; cache it so restarts and
      # reboots reuse the compiled blob instead of paying that again.
      OV_CACHE_DIR = "/var/cache/whisper-asr";
      # Python block-buffers stdout when it is not a tty, which would hold the
      # request log lines back instead of putting them in the journal.
      PYTHONUNBUFFERED = "1";
      # The stock driver cannot find the NPU compiler; the patched one loads it
      # from its own store path.
      ZE_ENABLE_ALT_DRIVERS = "${lib.getLib pkgs-npu.intel-npu-driver}/lib/libze_intel_npu.so";
    };

    # Reads its model, writes its cache, uses the NPU and listens on the LAN.
    serviceConfig = mylib.systemdHardening.service // {
      ExecStart = "${pythonEnv}/bin/python ${./asr/server.py}";
      CacheDirectory = "whisper-asr";
      DynamicUser = true;
      Restart = "on-failure";
      RestartSec = 5;

      RestrictAddressFamilies = [
        "AF_INET"
        "AF_UNIX"
      ];
      # The NPU is /dev/accel/accel0; allow that device class only.
      PrivateDevices = false;
      DevicePolicy = "closed";
      DeviceAllow = [ "char-accel rw" ];
      # OpenVINO's oneDNN kernels and libffi closures generate code at runtime.
      MemoryDenyWriteExecute = false;
      # OpenVINO sizes its thread pools from /proc/cpuinfo and /proc/meminfo.
      ProcSubset = "all";
    };
  };
}

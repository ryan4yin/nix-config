let
  sandbox = {
    CapabilityBoundingSet = "";
    NoNewPrivileges = true;
    PrivateDevices = true;
    ProtectSystem = "strict";
    SystemCallFilter = [
      "@system-service"
      "~@clock @cpu-emulation @debug @module @mount @obsolete @privileged @raw-io @reboot @swap"
    ];
  };
in
{
  # Only 80/443.
  caddy = sandbox // {
    CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
  };
  rustfs = sandbox;
  vmalert-homelab = sandbox;
  # The NPU is allowed through DeviceAllow instead.
  whisper-asr = sandbox // {
    PrivateDevices = false;
  };
}

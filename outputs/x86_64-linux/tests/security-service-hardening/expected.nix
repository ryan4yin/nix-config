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

  privilegedOneshot = {
    CapabilityBoundingSet = "";
    DeviceAllow = null;
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateNetwork = true;
    ProtectKernelTunables = null;
    ProtectSystem = "strict";
    RestrictAddressFamilies = [ "AF_UNIX" ];
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

  privilegedOneshot = {
    rapl-permissions = privilegedOneshot // {
      CapabilityBoundingSet = [ "CAP_CHOWN" ];
    };
    amdgpu-power-cap = privilegedOneshot;
    hdd-no-spindown = privilegedOneshot // {
      CapabilityBoundingSet = [ "CAP_SYS_RAWIO" ];
      DeviceAllow = [ "block-sd rw" ];
      PrivateDevices = false;
    };
  };
}

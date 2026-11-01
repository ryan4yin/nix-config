{ lib, outputs }:
let
  keys = [
    "CapabilityBoundingSet"
    "NoNewPrivileges"
    "PrivateDevices"
    "ProtectSystem"
    "SystemCallFilter"
  ];
  units =
    host: names:
    lib.genAttrs names (
      n: lib.getAttrs keys outputs.nixosConfigurations.${host}.config.systemd.services.${n}.serviceConfig
    );

  privilegedKeys = [
    "CapabilityBoundingSet"
    "DeviceAllow"
    "NoNewPrivileges"
    "PrivateDevices"
    "PrivateNetwork"
    "ProtectKernelTunables"
    "ProtectSystem"
    "RestrictAddressFamilies"
  ];
  privilegedUnit =
    host: name:
    let
      cfg = outputs.nixosConfigurations.${host}.config.systemd.services.${name}.serviceConfig;
    in
    lib.genAttrs privilegedKeys (key: cfg.${key} or null);
in
units "youko" [
  "caddy"
  "rustfs"
  "vmalert-homelab"
]
// units "aquamarine" [ "whisper-asr" ]
// {
  privilegedOneshot = {
    rapl-permissions = privilegedUnit "aquamarine" "rapl-permissions";
    amdgpu-power-cap = privilegedUnit "aquamarine" "amdgpu-power-cap";
    hdd-no-spindown = privilegedUnit "youko" "hdd-no-spindown";
  };
}

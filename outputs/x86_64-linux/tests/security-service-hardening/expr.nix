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
in
units "youko" [
  "caddy"
  "rustfs"
  "vmalert-homelab"
]
// units "aquamarine" [ "whisper-asr" ]

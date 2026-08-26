{ lib, ... }:
let
  # Universally-safe systemd sandboxing for network-facing services: no
  # filesystem-write impact and cannot break a well-behaved service.
  # ProtectSystem/ProtectHome/ReadWritePaths are intentionally EXCLUDED
  # (they risk breaking services; fix upstream in nixpkgs instead).
  safe = {
    NoNewPrivileges = true;
    PrivateTmp = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectKernelLogs = true;
    ProtectKernelReadonly = true;
    ProtectKernelIntegrity = true;
    ProtectKernelDevelopment = true;
    ProtectControlGroups = true;
    ProtectClock = true;
    ProtectHostname = true;
    RestrictRealtime = true;
    SystemCallArchitectures = [ "native" ];
  };
  services = [
    "caddy"
    "postgresql"
    "gitea"
    "sftpgo"
    "v2ray"
    "transmission"
  ];
in
{
  systemd.services = lib.listToAttrs (
    map (s: {
      name = s;
      value.serviceConfig = safe;
    }) services
  );
}

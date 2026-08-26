{
  lib,
  outputs,
}:
let
  cfg = outputs.nixosConfigurations.aquamarine.config;
  # NoNewPrivileges on a service (all six exist on aquamarine). Note: the
  # `? name` exists-check misbehaves on systemd.services here, so access directly.
  svc = name: (cfg.systemd.services.${name}.serviceConfig or { }).NoNewPrivileges or false;
in
{
  caddy = svc "caddy";
  postgresql = svc "postgresql";
  gitea = svc "gitea";
  sftpgo = svc "sftpgo";
  v2ray = svc "v2ray";
  transmission = svc "transmission";
}

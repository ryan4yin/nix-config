{
  lib,
  outputs,
}:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (
  name:
  let
    inherit (outputs.nixosConfigurations.${name}) config;
  in
  {
    auditd = config.security.auditd.enable;
    rootSession = lib.any (lib.hasSuffix "-k root-session") config.security.audit.rules;
    sessionsOnly = lib.elem "-a never,task -F auid=unset" config.security.audit.rules;
    agenixWatch = lib.elem "-a always,exit -F dir=/run/agenix.d -F perm=rwa -k credential-access" config.security.audit.rules;
  }
)

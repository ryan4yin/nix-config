{
  lib,
  outputs,
}:
# A VM host must install the guest system that nixosConfigurations evaluates,
# the one `just microvm-deploy` ships.
let
  inherit (outputs) nixosConfigurations;
  # hasInfix matches with a regex, which rejects strings that carry store context.
  plain = builtins.unsafeDiscardStringContext;
  vmHosts = [
    "shoryu"
    "shushou"
    "youko"
  ];
in
lib.mergeAttrsList (
  map (
    host:
    lib.mapAttrs' (
      guest: _:
      lib.nameValuePair "${host}/${guest}" (
        lib.hasInfix (plain "${nixosConfigurations.${guest}.config.system.build.toplevel}") (
          plain nixosConfigurations.${host}.config.systemd.services."install-microvm-${guest}".script
        )
      )
    ) nixosConfigurations.${host}.config.microvm.vms
  ) vmHosts
)

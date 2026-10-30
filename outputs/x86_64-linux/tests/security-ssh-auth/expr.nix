{
  lib,
  outputs,
}:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (
  name:
  let
    inherit (outputs.nixosConfigurations.${name}.config) services users;
  in
  {
    inherit (services.openssh.settings) PasswordAuthentication KbdInteractiveAuthentication;
    inherit (services.openssh) authorizedKeysInHomedir;
    # Keys that may open a root session without a forced command.
    unrestrictedRootKeys = builtins.length (
      lib.filter (key: !lib.hasPrefix "restrict," key) users.users.root.openssh.authorizedKeys.keys
    );
  }
  // lib.optionalAttrs (name == "aquamarine") {
    builderKeys = lib.filter (lib.hasPrefix "restrict,") users.users.root.openssh.authorizedKeys.keys;
  }
)

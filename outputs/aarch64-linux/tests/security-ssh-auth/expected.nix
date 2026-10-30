{
  lib,
  outputs,
  myvars,
}:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (
  name:
  {
    # Neither password nor PAM keyboard-interactive login is offered.
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    # Undeclared keys in ~/.ssh/authorized_keys are not honoured.
    authorizedKeysInHomedir = false;
    # Only the interactive admin keys open a root shell; remote-builder host keys
    # are pinned to the nix-daemon protocol, served by the system daemon.
    unrestrictedRootKeys = builtins.length (
      myvars.mainSshAuthorizedKeys ++ myvars.secondaryAuthorizedKeys
    );
  }
  // lib.optionalAttrs (name == "aquamarine") {
    builderKeys = map (
      key: ''restrict,command="nix-daemon --stdio --store daemon" ${key}''
    ) myvars.remoteBuilderClientKeys;
  }
)

{
  lib,
  outputs,
}:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (
  name:
  let
    isDesktop = name == "ai-niri" || name == "shoukei-niri";
  in
  {
    X11Forwarding = isDesktop;
    PermitRootLogin = if isDesktop then "no" else "prohibit-password";
  }
)

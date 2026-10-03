{ lib, outputs }:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (_: {
  collector = true;
  directory = true;
  unprivileged = true;
  noNewPrivileges = true;
  timerMatchesExporter = true;
  boundedInterval = true;
})

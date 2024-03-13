{
  lib,
  outputs,
}: let
  specialExpected = {
    "ai-hyprland" = "ai";
    "ai-i3" = "ai";
    "shoukei-hyprland" = "shoukei";
    "shoukei-i3" = "shoukei";
  };
  specialHostNames = builtins.attrNames specialExpected;

  otherHosts = builtins.removeAttrs outputs.nixosConfigurations specialHostNames;
  otherHostsNames = builtins.attrNames otherHosts;
  # other hosts's hostName is the same as the nixosConfigurations name
  otherExpected = lib.genAttrs otherHostsNames (name: name);
in (specialExpected // otherExpected)

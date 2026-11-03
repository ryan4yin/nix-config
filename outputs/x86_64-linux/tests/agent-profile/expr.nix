# The `agent` profile (hosts/README.md#host-profiles): every agent host gets
# the full TUI home role, and the system side only carries what needs root.
{
  myvars,
  lib,
  outputs,
}:
let
  username = myvars.username;
  hosts = [
    "aquamarine"
    "ruby"
    "kana"
  ];
  hasPackage = name: lib.any (package: (package.pname or "") == name);
in
lib.genAttrs hosts (
  name:
  let
    system = outputs.nixosConfigurations.${name}.config;
    home = system.home-manager.users.${username};
  in
  {
    # home role: home/linux/tui.nix
    agentsFromHome = hasPackage "codex" home.home.packages;
    devToolsFromHome = hasPackage "kubectl" home.home.packages;
    # ~/.secrets is synced to the desktops only; sourcing it would break nushell.
    nushellSecrets = home.modules.shell.secrets.enable;

    # system module: modules/nixos/agent.nix
    nixLd = system.programs.nix-ld.enable;
    rootlessPodman = system.virtualisation.podman.enable;
    docker = system.virtualisation.docker.enable;
    linger = system.users.users.${username}.linger;
    # User tools stay out of the system profile.
    agentsInSystem = hasPackage "codex" system.environment.systemPackages;

    # host switch
    computerUse = system.modules.desktop.computerUse.enable;

    # Full-host NixOS test export.
    nixosTest = outputs.packages ? "${name}-nixos-tests";
  }
)

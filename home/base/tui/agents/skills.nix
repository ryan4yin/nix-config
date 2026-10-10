{ config, ... }:
let
  skill = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/agents/skills/git-delivery";
in
{
  # Link each custom skill separately so third-party skills remain unmanaged.
  home.file.".agents/skills/git-delivery".source = skill;
}

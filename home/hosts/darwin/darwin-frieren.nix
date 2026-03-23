{ config, ... }:
let
  hostName = "frieren";
in
{
  imports = [ ../../darwin ];

  programs.ssh.matchBlocks."github.com".identityFile =
    "${config.home.homeDirectory}/.ssh/${hostName}";
}

{ config, ... }:
let
  hostName = "fern";
in
{
  imports = [ ../../darwin ];

  programs.ssh.matchBlocks."github.com".identityFile =
    "${config.home.homeDirectory}/.ssh/${hostName}";
}

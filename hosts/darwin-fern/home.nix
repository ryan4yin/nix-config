{config, ...}: let
  hostName = "fern";
in {
  programs.ssh.matchBlocks."github.com".identityFile = "${config.home.homeDirectory}/.ssh/${hostName}";
}

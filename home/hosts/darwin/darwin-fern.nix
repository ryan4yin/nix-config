{ config, ... }:
let
  hostName = "fern";
in
{
  imports = [ ../../darwin ];

  programs.ssh.settings."github.com".IdentityFile = "${config.home.homeDirectory}/.ssh/${hostName}";
}

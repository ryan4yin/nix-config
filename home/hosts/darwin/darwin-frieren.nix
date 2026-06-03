{ config, ... }:
let
  hostName = "frieren";
in
{
  imports = [ ../../darwin ];

  programs.ssh.settings."github.com".IdentityFile = "${config.home.homeDirectory}/.ssh/${hostName}";
}

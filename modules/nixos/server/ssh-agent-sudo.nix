{
  lib,
  pkgs,
  myvars,
  ...
}:
{
  # sudo over SSH accepts a CanoKey touch through the forwarded agent; without
  # it, sudo asks for the password as before. Only the hardware-backed keys are
  # trusted, so a file key loaded in the agent cannot sign for sudo silently.
  # Setup and limits: docs/security-keys.md.
  security.pam.rssh = {
    enable = true;
    settings = {
      auth_key_file = "${pkgs.writeText "sudo-ssh-agent-keys" (lib.concatLines myvars.canokeySshKeys)}";
      cue = true;
    };
  };
  security.pam.services.sudo.rssh = true;
}

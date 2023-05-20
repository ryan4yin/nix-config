# This file is not imported into your NixOS configuration. It is only used for the agenix CLI.

let
  # get user's ssh public key by command:
  #     cat ~/.ssh/id_ed25519.pub
  # if you do not have one, you can generate it by command:
  #     ssh-keygen -t ed25519
  ryan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJx3Sk20pLL1b2PPKZey2oTyioODrErq83xG78YpFBoj";
  users = [ ryan ];

  # get system's ssh public key by command:
  #    cat /etc/ssh/ssh_host_ed25519_key.pub
  msi-rtx4090 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICGeXNCazqiqxn8TmbCRjA+pLWrxwenn+CFhizBMP6en root@msi-rtx4090";
  systems = [ msi-rtx4090 ];
in
{
  "./encrypt/wg-business.conf.age".publicKeys = users ++ systems;
  "./encrypt/smb-credentials.age".publicKeys = users ++ systems;
  # "./encrypt/secret123.age".publicKeys = [ user1 system1 ];
}
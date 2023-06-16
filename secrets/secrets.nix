# This file is not imported into your NixOS configuration. It is only used for the agenix CLI.

let
  # get my ssh public key for agenix by command:
  #     cat ~/.ssh/juliet-age.pub
  # if you do not have one, you can generate it by command:
  #     ssh-keygen -t ed25519
  ryan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP7FbSWehHoOWCZMDEHLiPCa1ZJ5c6hYMzhKdXssPpE9 ryan@juliet-age";
  users = [ ryan ];

  # get system's ssh public key by command:
  #    cat /etc/ssh/ssh_host_ed25519_key.pub
  ai = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICGeXNCazqiqxn8TmbCRjA+pLWrxwenn+CFhizBMP6en root@ai";
  systems = [ ai ];
in
{
  "./encrypt/wg-business.conf.age".publicKeys = users ++ systems;
  "./encrypt/smb-credentials.age".publicKeys = users ++ systems;
  # "./encrypt/secret123.age".publicKeys = [ user1 system1 ];
}

{ lib }:
let
  # CanoKey resident SSH keys: the only user keys, and the only keys pam_rssh
  # accepts for sudo on servers through the forwarded agent
  # (modules/nixos/server/ssh-agent-sudo.nix).
  canokeySshKeys = [
    # canokey-tea (main)
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINuvSs4skjxNCTvN5k8rihUXOCst/XChw37aDeOmz+vvAAAAEHNzaDpyeWFuNHlpbi10ZWE= ryan@canokey-tea"
    # canokey-moe (backup)
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIEZKUA4pNWvXKCpPQZHgctlR6O/71QirBQNt2RC5QsdfAAAAEHNzaDpyeWFuNHlpbi1tb2U= ryan@canokey-moe"
  ];
in
{
  inherit canokeySshKeys;
  username = "ryan";
  userfullname = "Ryan Yin";
  useremail = "xiaoyin_c@qq.com";
  networking = import ./networking.nix { inherit lib; };
  ports = import ./ports.nix;
  # Generated using: mkpasswd -m yescrypt --rounds=11
  # Password: long, strong random string (full charset)
  # Rotation policy: changed annually
  # Purpose: system login password only
  # https://man.archlinux.org/man/crypt.5.en
  initialHashedPassword = "$y$jFT$RBapCH3F6bc0uSF.FaUGB.$rvhiVvcCKxkkumDFLONV5zFP1lsv1VyZ1ErH.r2rNk3";
  # Public keys that log in to all my PCs, Macbooks, and servers.
  mainSshAuthorizedKeys = canokeySshKeys;
  # CanoKey U2F registrations for sudo (modules/nixos/desktop/canokey.nix).
  # Key handles and public keys only, so they are safe to commit.
  canokeyU2fKeys = [
    # canokey-tea (main)
    "1pS52FIPHfevn97Hiz5+OOFe0OaPBPqIrsD0r/mC/YIAAdEYDZIbm8kTBUGA49wXW0ZvSpF9VNYh2w84Xz9nAIAW////+Q==,LkVavaZRhu8nHhIj1r2N78BwOlU32Y/AAGkekzn5DLQCztnMs4uslIAvzzaNNCpaDu49xwZm4TqPBDKg0IuIlA==,es256,+presence"
    # canokey-moe (backup)
    "dxdeYeJTx40VhgPll05COx1Vn3WRKuXNgtHCTpTSyq0AAdEYDZIbm8kTBUGA49wXW0ZvSpF9VNYh2w84Xz9nAIAW////+Q==,cpBHKCdambMTGau3+eXVyv4JWQK7ZQ+8AbRt0EevCL0DeftDdXX6aatHSpbiXAhjip3R8pfeXi6GTW67YpdCPw==,es256,+presence"
  ];
  secondaryAuthorizedKeys = [
    # the backup ssh keys for disaster recovery
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMzYT0Fpcp681eHY5FJV2G8Mve53iX3hMOLGbVvfL+TF ryan@romantic"
  ];
  # The SSH host keys of the machines whose nix-daemons build through aquamarine
  # (modules/nixos/base/remote-builders.nix).
  remoteBuilderClientKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINHZtzeaQyXwuRMLzoOAuTu8P9bu5yc5MBwo5LI3iWBV root@ai"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILDkbOwOeuAem8BKbyTDliRiTfHVAFdiVpAKh1bhs2s0 root@shoukei"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGSSw4Oa8CaAeYXq2+O/SHHICaoUTFTGYjW5R9MzZ9Nj root@shoryu"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK4Po3tzTPVKEE5fAk4RQfhTvA4h+AurnkEiM7RYdND9 root@shushou"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEs8b3CmxM+utXZVKvJBssXBupBXvvzjHP40HcY7PSyZ root@youko"
  ];
}

{ pkgs, agenix, mysecrets, ... }:

{
  imports = [
    (agenix.nixosModules.default)
  ];

  environment.systemPackages = [
    agenix.packages."${pkgs.system}".default
  ];

  # if you changed this key, you need to regenerate all encrypt files from the decrypt contents!
  age.identityPaths = [ "/home/ryan/.ssh/juliet-age" ];

  age.secretsDir = "/run/agenix/";

  ############################################################################
  #
  # The following secrets are used by NixOS Modules
  #
  ############################################################################

  # wireguard config used with `wg-quick up wg-business`  
  age.secrets."wg-business.conf" = {
    # wether secrets are symlinked to age.secrets.<name>.path(default to true)
    symlink = true;
    # target path for decrypted file
    path = "/etc/wireguard/";
    # encrypted file path
    file = "${mysecrets}/wg-business.conf.age";
    mode = "0400";
    owner = "root";
    group = "root";
  };

  # smb-credentials is referenced in /etc/fstab, by ../hosts/ai/cifs-mount.nix
  age.secrets."smb-credentials" = {
    file = "${mysecrets}/smb-credentials.age";
  };


  ############################################################################
  #
  # The following secrets are used by home-manager modules
  # So they should be readable by the user `ryan`
  #
  ############################################################################

  age.secrets."alias-for-work.nushell" = {
    # path = "/etc/agenix/";
    file = "${mysecrets}/alias-for-work.nushell.age";
    mode = "0600";
    owner = "ryan";
    group = "ryan";
  };
  age.secrets."alias-for-work.bash" = {
    # path = "/etc/agenix/";
    file = "${mysecrets}/alias-for-work.bash.age";
    mode = "0600";
    owner = "ryan";
    group = "ryan";
  };
}

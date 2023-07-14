{ pkgs, agenix, mysecrets, ... }:

{
  imports = [
    agenix.nixosModules.default
  ];

  environment.systemPackages = [
    agenix.packages."${pkgs.system}".default
  ];

  # if you changed this key, you need to regenerate all encrypt files from the decrypt contents!
  age.identityPaths = [ "/home/ryan/.ssh/juliet-age" ];

  # wireguard config used with `wg-quick up wg-business`  
  age.secrets."wg-business.conf" = {
    # wether secrets are symlinked to age.secrets.<name>.path
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
    # wether secrets are symlinked to age.secrets.<name>.path
    symlink = true;
    # encrypted file path
    file = "${mysecrets}/smb-credentials.age";
  };

  age.secrets."alias-for-work.nushell" = {
    # wether secrets are symlinked to age.secrets.<name>.path
    symlink = false;
    # encrypted file path
    file = "${mysecrets}/alias-for-work.nushell.age";
  };
  age.secrets."alias-for-work.bash" = {
    # wether secrets are symlinked to age.secrets.<name>.path
    symlink = false;
    # encrypted file path
    file = "${mysecrets}/alias-for-work.bash.age";
  };
}

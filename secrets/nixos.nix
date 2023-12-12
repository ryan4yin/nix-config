{
  config,
  pkgs,
  agenix,
  mysecrets,

  username,
  ...
}: {
  imports = [
    agenix.nixosModules.default
  ];

  environment.systemPackages = [
    agenix.packages."${pkgs.system}".default
  ];

  # if you changed this key, you need to regenerate all encrypt files from the decrypt contents!
  age.identityPaths = [
    # To decrypt secrets on boot, this key should exists when the system is booting,
    # so we should use the real key file path(prefixed by `/persistent/`) here, instead of the path mounted by impermanence.
    "/persistent/home/${username}/.ssh/juliet-age" # Linux
  ];

  # Used only by NixOS Modules
  # smb-credentials is referenced in /etc/fstab, by ../hosts/ai/cifs-mount.nix
  age.secrets."smb-credentials" = {
    file = "${mysecrets}/smb-credentials.age";
  };

  age.secrets = {
    "wg-business.conf" = {
      file = "${mysecrets}/wg-business.conf.age";
    };

    # alias-for-work
    "alias-for-work.nushell" = {
      file = "${mysecrets}/alias-for-work.nushell.age";
    };
    "alias-for-work.bash" = {
      file = "${mysecrets}/alias-for-work.bash.age";
    };
  };

  # place secrets in /etc/
  environment.etc = {
    # wireguard config used with `wg-quick up wg-business`
    "wireguard/wg-business.conf" = {
      source = config.age.secrets."wg-business.conf".path;
    };

    # The following secrets are used by home-manager modules
    # So we need to make then readable by the user
    "agenix/alias-for-work.nushell" = {
      source = config.age.secrets."alias-for-work.nushell".path;
      mode = "0644";
    };
    "agenix/alias-for-work.bash" = {
      source = config.age.secrets."alias-for-work.bash".path;
      mode = "0644";
    };
  };
}

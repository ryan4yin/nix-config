{
  config,
  pkgs,
  agenix,
  mysecrets,
  username,
  ...
}: {
  imports = [
    agenix.darwinModules.default
  ];

  environment.systemPackages = [
    agenix.packages."${pkgs.system}".default
  ];

  # if you changed this key, you need to regenerate all encrypt files from the decrypt contents!
  age.identityPaths = [
    "/Users/${username}/.ssh/juliet-age" # macOS
  ];

  age.secrets = {
    "wg-business.conf" = {
      file = "${mysecrets}/wg-business.conf.age";
      owner = username;
    };

    # alias-for-work
    "alias-for-work.nushell" = {
      file = "${mysecrets}/alias-for-work.nushell.age";
      mode = "0600";
      owner = username;
    };
    "alias-for-work.bash" = {
      file = "${mysecrets}/alias-for-work.bash.age";
      mode = "0600";
      owner = username;
    };

    "nix-access-tokens" = {
      file = "${mysecrets}/nix-access-tokens.age";
      mode = "0600";
      owner = username;
    };
  };

  # place secrets in /etc/
  environment.etc = {
    # wireguard config used with `wg-quick up wg-business`
    # Fix DNS for WireGuard on macOS: https://github.com/ryan4yin/nix-config/issues/5
    "wireguard/wg-business.conf" = {
      source = config.age.secrets."wg-business.conf".path;
    };

    # The following secrets are used by home-manager modules
    # But nix-darwin doesn't support environment.etc.<name>.mode
    # So we need to change its mode manually
    "agenix/alias-for-work.nushell" = {
      source = config.age.secrets."alias-for-work.nushell".path;
    };
    "agenix/alias-for-work.bash" = {
      source = config.age.secrets."alias-for-work.bash".path;
    };
  };

  # both the original file and the symlink should be readable and executable by the user
  #
  # activationScripts are executed every time you run `nixos-rebuild` / `darwin-rebuild` or boot your system
  system.activationScripts.postActivation.text = ''
    sudo chown ${username} /etc/agenix/*
  '';
}

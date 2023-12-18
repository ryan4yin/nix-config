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

  # activationScripts are executed every time you run `nixos-rebuild` / `darwin-rebuild`.
  system.activationScripts.postActivation.text = ''
    chmod 644 /etc/agenix/*
  '';
  # When you eboot the system, only these scripts will be executed:
  #    https://github.com/LnL7/nix-darwin/blob/4eb1c549a9d4/modules/services/activate-system/default.nix6
  # So we need to add the following line to the script:
  launchd.daemons.activate-system.script = ''
    set -e
    set -o pipefail
    export PATH="${pkgs.gnugrep}/bin:${pkgs.coreutils}/bin:@out@/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin"

    systemConfig=$(cat ${config.system.profile}/systemConfig)

    # Make this configuration the current configuration.
    # The readlink is there to ensure that when $systemConfig = /system
    # (which is a symlink to the store), /run/current-system is still
    # used as a garbage collection root.
    ln -sfn $(cat ${config.system.profile}/systemConfig) /run/current-system

    # Prevent the current configuration from being garbage-collected.
    ln -sfn /run/current-system /nix/var/nix/gcroots/current-system

    ${config.system.activationScripts.etcChecks.text}
    ${config.system.activationScripts.etc.text}
    ${config.system.activationScripts.keyboard.text}

    # The following line is added by me
    ${config.system.activationScripts.postActivation.text}
  '';
}

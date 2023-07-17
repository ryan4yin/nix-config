
{ config, pkgs, agenix, mysecrets, ... }:

{
  imports = [
    agenix.darwinModules.default
  ];

  environment.systemPackages = [
    agenix.packages."${pkgs.system}".default
  ];

  # if you changed this key, you need to regenerate all encrypt files from the decrypt contents!
  age.identityPaths = [ 
    "/Users/ryan/.ssh/juliet-age"  # macOS
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
  # but not when you reboot the system, so currently you need to run those commands manually after reboot...
  system.activationScripts.postUserActivation.text = ''
    sudo chmod 644 /etc/agenix/alias-for-work.nushell
    sudo chmod 644 /etc/agenix/alias-for-work.bash
  '';

}

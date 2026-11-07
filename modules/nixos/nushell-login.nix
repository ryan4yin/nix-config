{ myvars, pkgs, ... }:
{
  users.users.${myvars.username}.shell = pkgs.nushell;
  environment.shells = [ pkgs.nushell ];

  # Hosts without Home Manager get no Nix-managed `config.nu`, so nushell
  # generates one in `~/.config/nushell` with the welcome banner enabled; on a
  # tmpfs `$HOME` that is a fresh banner after every boot. This vendor autoload
  # is read after `config.nu`, so it turns the banner off without taking over
  # the user's own config file.
  programs.nushell = {
    enable = true;
    interactiveShellInit = "$env.config.show_banner = false";
  };
}

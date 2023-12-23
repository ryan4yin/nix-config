{config, ...}: {
  nix.extraOptions = ''
    !include ${config.age.secrets.nix-access-tokens.path}
  '';

  # security with polkit
  services.power-profiles-daemon = {
    enable = true;
  };
  security.polkit.enable = true;
  # security with gnome-kering
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
}

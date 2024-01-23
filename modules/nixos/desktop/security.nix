{config, ...}: {
  nix.extraOptions = ''
    !include ${config.age.secrets.nix-access-tokens.path}
  '';

  # security with polkit
  security.polkit.enable = true;
  # security with gnome-kering
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # gpg agent with pinentry
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "curses";
    enableSSHSupport = false;
  };
}

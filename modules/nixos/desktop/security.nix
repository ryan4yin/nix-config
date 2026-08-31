{
  config,
  pkgs,
  ...
}:
{
  # security with polkit
  security.polkit.enable = true;
  # security with gnome-kering
  services.gnome = {
    gnome-keyring.enable = true;
    # Use gnome keyring's SSH Agent
    # https://wiki.gnome.org/Projects/GnomeKeyring/Ssh
    gcr-ssh-agent.enable = false;
  };
  # seahorse is a GUI App for GNOME Keyring.
  # Pitfall: never use seahorse's "New -> Default keyring". pam_gnome_keyring
  # hardcodes the keyring name "login" (unlocks/syncs only login.keyring),
  # while Secret Service apps (gh, browsers) use the keyring named in
  # ~/.local/share/keyrings/default. Creating a separate "Default keyring"
  # forks secrets into a second container whose password never syncs with the
  # login password, causing "Unlock Login Keyring" prompt desyncs.
  # Keep everything in "login" and leave the `default` pointer unset (or
  # pointing at "login").
  programs.seahorse.enable = true;
  # The OpenSSH agent remembers private keys for you
  # so that you don’t have to type in passphrases every time you make an SSH connection.
  # Use `ssh-add` to add a key to the agent.
  programs.ssh.startAgent = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  # Keep the login keyring password in sync with the login password when it is
  # changed via `passwd`. Without this, pam_gnome_keyring only unlocks the
  # keyring at login and a `passwd` change desyncs the two, causing
  # "Unlock Login Keyring" prompt loops (and gh asking for a separate
  # "keyring password").
  security.pam.services.passwd.enableGnomeKeyring = true;

  # gpg agent with pinentry
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
    enableSSHSupport = false;
    settings.default-cache-ttl = 4 * 60 * 60; # 4 hours
  };
}

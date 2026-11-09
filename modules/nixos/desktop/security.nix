{
  config,
  pkgs,
  ...
}:
{
  # security with polkit
  security.polkit.enable = true;
  # oo7 provides the Secret Service (gh, browsers) and, through oo7-portal, the
  # Secret portal for sandboxed apps. Its first unlock migrates the
  # gnome-keyring files in ~/.local/share/keyrings to keyrings/v1/ and deletes
  # the originals, so switching back to gnome-keyring needs a backup.
  services.oo7.enable = true;
  services.gnome = {
    # programs.niri enables it by default.
    gnome-keyring.enable = false;
    # Not gcr's SSH agent: OpenSSH's own agent runs instead
    # (programs.ssh.startAgent below).
    # https://wiki.gnome.org/Projects/GnomeKeyring/Ssh
    gcr-ssh-agent.enable = false;
  };
  # oo7 shows unlock prompts through gcr's org.gnome.keyring.SystemPrompter,
  # which the gnome-keyring module used to register.
  services.dbus.packages = [ pkgs.gcr_3 ];
  # seahorse manages any Secret Service. pam_oo7 unlocks, and re-keys on
  # `passwd`, only the keyrings whose password is the login password.
  programs.seahorse.enable = true;
  # The OpenSSH agent remembers private keys for you
  # so that you don’t have to type in passphrases every time you make an SSH connection.
  # Use `ssh-add` to add a key to the agent.
  programs.ssh.startAgent = true;
  # services.oo7 enables pam_oo7 for `login`, which greetd's stack includes.
  # Without `passwd`, a password change leaves the keyring on the old password
  # and oo7 prompts for it after login.
  security.pam.services.passwd.oo7.enable = true;

  # gpg agent with pinentry
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
    enableSSHSupport = false;
    settings.default-cache-ttl = 4 * 60 * 60; # 4 hours
  };
}

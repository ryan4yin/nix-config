{ myvars, ... }:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${myvars.username}" = {
    home = "/Users/${myvars.username}";

    # The login shell is set imperatively (`chsh -s /bin/zsh`), not declaratively here.
    # DO NOT change the system's default shell to nushell! it will break some apps!
    # It's better to change only kitty/wezterm & other terminal emulator's shell to nushell!
  };
}

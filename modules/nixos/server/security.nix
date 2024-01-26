{username, ...}: {
  # Public Keys that can be used to login to all my servers.
  users.users.${username}.openssh.authorizedKeys.keys = [
    # TODO update keys here
    "ssh-ed25519 xxx ryan@romantic"
  ];
}

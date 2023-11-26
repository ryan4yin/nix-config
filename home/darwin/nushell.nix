{config, ...}: {
  # nix-darwin do not set PATH for nushell! so we need to do it manually
  # this is a workaround to add nix's PATH to nushell
  programs.nushell.extraConfig = ''
    $env.PATH = ([
      "${config.home.homeDirectory}/bin"
      "${config.home.homeDirectory}/.local/bin"
      "${config.home.homeDirectory}/go/bin"
      "/usr/local/bin"
      "${config.home.homeDirectory}/.nix-profile/bin"
      "/etc/profiles/per-user/${config.home.username}/bin"
      "/run/current-system/sw/bin"
      "/nix/var/nix/profiles/default/bin"

      ($env.PATH | split row (char esep))
    ] | flatten)
  '';
}

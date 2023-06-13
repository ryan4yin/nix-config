{ ... }: {
  # nushell's PATH do not include nix-darwin's PATH
  # this is a workaround to add nix-darwin's PATH to nushell's PATH
  programs.nushell.extraConfig = ''
    let-env PATH = ([

      "~/.nix-profile/bin"
      "/etc/profiles/per-user/admin/bin"
      "/run/current-system/sw/bin"
      "/nix/var/nix/profiles/default/bin"

      ($env.PATH | split row (char esep))
    ] | flatten)
  '';
}
{
  pkgs,
  myvars,
  ...
}:
#############################################################
#
#  The `agent` profile (hosts/README.md#host-profiles): a headless
#  host whose user tools come from the Home Manager TUI role
#  (home/linux/tui.nix). This module only carries what needs root.
#
#############################################################
{
  imports = [
    ./server/server.nix
    # off by default; a host turns it on with modules.desktop.computerUse.enable
    ./desktop/computer-use.nix
  ];

  # Rootless Podman for agents and the images they build.
  virtualisation.podman.enable = true;

  # Keep the user systemd manager running after logout and start it at boot,
  # so agent and computer-use user services run without a login session.
  users.users."${myvars.username}".linger = true;

  # https://github.com/Mic92/nix-ld
  #
  # nix-ld will install itself at `/lib64/ld-linux-x86-64.so.2` so that
  # it can be used as the dynamic linker for non-NixOS binaries.
  #
  # nix-ld works like a middleware between the actual link loader located at `/nix/store/.../ld-linux-x86-64.so.2`
  # and the non-NixOS binaries. It will:
  #
  #   1. read the `NIX_LD` environment variable and use it to find the actual link loader.
  #   2. read the `NIX_LD_LIBRARY_PATH` environment variable and use it to set the `LD_LIBRARY_PATH` environment variable
  #      for the actual link loader.
  #
  # nix-ld's nixos module will set default values for `NIX_LD` and `NIX_LD_LIBRARY_PATH` environment variables, so
  # it can work out of the box:
  #
  #  - https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/programs/nix-ld.nix#L42-L45
  #
  # You can overwrite `NIX_LD_LIBRARY_PATH` in the environment where you run the non-NixOS binaries to customize the
  # search path for shared libraries.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
    ];
  };
}

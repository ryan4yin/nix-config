{ lib, ... }:
{
  # auto upgrade nix to the unstable version
  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/tools/package-management/nix/default.nix#L284
  # nix.package = pkgs.nixVersions.latest;

  # https://lix.systems/add-to-config/
  # nix.package = pkgs.lix;

  # to install chrome, you need to enable unfree packages
  nixpkgs.config.allowUnfree = lib.mkForce true;

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # Manual optimise storage: nix-store --optimise
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.settings = {
    auto-optimise-store = true;

    # Reference: https://github.com/NixOS/nixpkgs/pull/478109
    # NixOS tests using systemd-nspawn containers require the Nix daemon to be
    # configured with the following settings:
    auto-allocate-uids = true;
    extra-system-features = [ "uid-range" ];
    experimental-features = [
      "auto-allocate-uids"
      "cgroups"
    ];
    # Use extra-sandbox-paths instead of sandbox-paths here. The plain
    # sandbox-paths setting replaces Nix's compiled sandbox defaults, including
    # the sandbox shell that provides /bin/sh for builders with legacy shebangs.
    # extra-sandbox-paths keeps those defaults and only adds the paths we need.
    # After deploying, verify the effective daemon config with:
    #   nix config show | grep sandbox-paths
    extra-sandbox-paths = [
      "/dev/net"
    ];
  };

  nix.channel.enable = false; # remove nix-channel related tools & configs, we use flakes instead.
}

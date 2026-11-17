{
  config,
  lib,
  nixpkgsConfig,
  ...
}:
let
  # Store hygiene below applies to physical hosts only: VM guests build nothing
  # locally (Colmena pushes their closures) and MicroVM guests share the host's
  # read-only store. `hardwareTools` is off on every guest.
  isPhysical = config.modules.hardwareTools.enable;
  GiB = 1024 * 1024 * 1024;
in
{
  # https://lix.systems/add-to-config/
  # nix.package = pkgs.lix;

  # NixOS only: darwin's nixpkgs.pkgs instance already carries it (lib/macosSystem.nix),
  # and nixpkgs rejects nixpkgs.config next to nixpkgs.pkgs.
  nixpkgs.config = nixpkgsConfig;

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # A run can fail while a store path is still in use; retry instead of waiting a week.
  systemd.services.nix-gc.serviceConfig.Restart = lib.mkIf isPhysical "on-failure";

  # Builds cut off by a crash or power loss stay in the build dir (/nix/var/nix/builds,
  # Nix's default `build-dir`) on the persistent pool. Clear it at boot, before
  # nix-daemon runs; the line is boot-only, so Nix's own 7-day tmpfiles rule still
  # ages the directory at runtime.
  systemd.tmpfiles.rules = lib.mkIf isPhysical [ "D! /nix/var/nix/builds 0755 root root -" ];

  # Manual optimise storage: nix-store --optimise
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.settings = {
    auto-optimise-store = true;

    # When a build leaves less than 20 GiB free, GC until 50 GiB is free. The
    # store shares its btrfs pool with /persistent (databases, VM images), which
    # must keep room to write.
    min-free = lib.mkIf isPhysical (20 * GiB);
    max-free = lib.mkIf isPhysical (50 * GiB);

    # Required to run nixpkgs' systemd-nspawn based NixOS tests locally (used
    # by the nixpkgs-review workflow). These are daemon-wide settings, so every
    # local build pays the small uid/cgroup allocation overhead; drop them if
    # you stop running those tests.
    # Reference: https://github.com/NixOS/nixpkgs/pull/478109
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

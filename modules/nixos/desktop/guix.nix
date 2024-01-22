{
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/guix/default.nix
  services.guix = {
    enable = true;
    # The store directory where the Guix service will serve to/from.
    # NOTE: most of the cached builds are assumed to be in `/gnu/store`.
    storeDir = "/gnu/store";
    # The state directory where Guix service will store its data such as its
    # user-specific profiles, cache, and state files.
    stateDir = "/var";
    gc = {
      enable = true;
      # https://guix.gnu.org/en/manual/en/html_node/Invoking-guix-gc.html
      extraArgs = [
        "--delete-generations=1m"
        "--free-space=10G"
        "--optimize"
      ];
    };
  };
}

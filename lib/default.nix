{lib, ...}: {
  colmenaSystem = import ./colmenaSystem.nix;
  macosSystem = import ./macosSystem.nix;
  nixosSystem = import ./nixosSystem.nix;
  attrs = import ./attrs.nix {inherit lib;};
  scanPaths = path:
    builtins.map
    (f: (path + "/${f}"))
    (builtins.filter # find all overlay files in the current directory
      
      (
        f:
          f
          != "default.nix" # ignore default.nix
          && f != "README.md" # ignore README.md
      )
      (builtins.attrNames (builtins.readDir path)));
}

{lib, ...}: {
  colmenaSystem = import ./colmenaSystem.nix;
  macosSystem = import ./macosSystem.nix;
  nixosSystem = import ./nixosSystem.nix;

  attrs = import ./attrs.nix {inherit lib;};

  genK3sServerModule = import ./genK3sServerModule.nix;
  genK3sAgentModule = import ./genK3sAgentModule.nix;
  genKubeVirtHostModule = import ./genKubeVirtHostModule.nix;
  genKubeVirtGuestModule = import ./genKubeVirtGuestModule.nix;

  # use path relative to the root of the project
  relativeToRoot = lib.path.append ../.;
  scanPaths = path:
    builtins.map
    (f: (path + "/${f}"))
    (builtins.attrNames
      (lib.attrsets.filterAttrs
        (
          path: _type:
            (_type == "directory") # include directories
            || (
              (path != "default.nix") # ignore default.nix
              && (lib.strings.hasSuffix ".nix" path) # include .nix files
            )
        )
        (builtins.readDir path)));
}

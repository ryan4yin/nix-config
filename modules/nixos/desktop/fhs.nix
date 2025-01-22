{pkgs, ...}: {
  # FHS environment, flatpak, appImage, etc.
  environment.systemPackages = [
    # create a fhs environment by command `fhs`, so we can run non-nixos packages in nixos!
    (
      let
        base = pkgs.appimageTools.defaultFhsEnvArgs;
      in
        pkgs.buildFHSEnv (base
          // {
            name = "fhs";
            targetPkgs = pkgs: (base.targetPkgs pkgs) ++ [pkgs.pkg-config];
            profile = "export FHS=1";
            runScript = "bash";
            extraOutputsToInstall = ["dev"];
          })
    )
  ];

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
  #  - https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/programs/nix-ld.nix#L37-L40
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

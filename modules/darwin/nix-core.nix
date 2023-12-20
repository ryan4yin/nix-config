{pkgs, ...}: {
  ###################################################################################
  #
  #  Core configuration for nix-darwin
  #
  #  All the configuration options are documented here:
  #    https://daiderd.com/nix-darwin/manual/index.html#sec-options
  #
  ###################################################################################

  # Fix: https://github.com/LnL7/nix-darwin/issues/149#issuecomment-1741720259
  # nix is installed via DeterminateSystems's nix-installer.
  environment.etc."zshrc".knownSha256Hashes = [
    "b9902f2020c636aeda956a74b5ae11882d53e206d1aa50b3abe591a8144fa710"  # nix-installer on harmonica
  ];
  environment.etc."bashrc".knownSha256Hashes = [
    "204d2a960b3ab80e51748d3db0b63d940347ba71119ae6f14cccfec35da56cce"    # nix-installer on harmonica
    "6ffdf5a198ffe73fbcd17def767f52093b42b29149d4a3e911b49ebcb9785101"    # nix-installer on fern
   ];
  environment.etc."zshenv".knownSha256Hashes = [
    "383a89c1f79c3bcfd2ff39a2b73b5103d0303161b3be9eac88fce83e0789f0b7"    # nix-installer on harmonica
    "0c544e42afe7836de9ba933d93f46043b12f58ae484ff8cfb02716353f1dba5f"    # nix-installer on fern
  ];


  environment.etc."shells".knownSha256Hashes = [
    "9d5aa72f807091b481820d12e693093293ba33c73854909ad7b0fb192c2db193"     # nix-installer on fern
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  # Disable auto-optimise-store because of this issue:
  #   https://github.com/NixOS/nix/issues/7273
  # "error: cannot link '/nix/store/.tmp-link-xxxxx-xxxxx' to '/nix/store/.links/xxxx': File exists"
  nix.settings.auto-optimise-store = false;

  nix.gc.automatic = false;
}

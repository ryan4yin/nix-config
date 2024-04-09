{lib, ...}:
# ===================================================================
# Remove packages that are not well supported for the Darwin platform
# ===================================================================
let
  brokenPackages = [
    "terraform"
    "terraformer"
    "packer"
    "git-trim"
    "conda"
    "mitmproxy"
    "insomnia"
    "wireshark"
    "jsonnet"
    "zls"
    "verible"
    "gdb"
    "ncdu"
  ];
in {
  nixpkgs.overlays = [
    (_: super: let
      removeUnwantedPackages = pname:
        lib.warn "the ${pname} has been removed on the darwin platform"
        super.emptyDirectory;
    in
      lib.genAttrs
      brokenPackages
      removeUnwantedPackages)
  ];
}

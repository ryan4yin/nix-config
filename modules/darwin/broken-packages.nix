{ lib, ... }:
# ===================================================================
# Remove packages that are not well supported for the Darwin platform
# ===================================================================
let
  brokenPackages = [
    "conda"
    "mitmproxy"
    "wireshark"
    "verible"
  ];
in
{
  nixpkgs.overlays = [
    (
      _: super:
      let
        removeUnwantedPackages =
          pname: lib.warn "the ${pname} has been removed on the darwin platform" super.emptyDirectory;
      in
      lib.genAttrs brokenPackages removeUnwantedPackages
    )
  ];
}

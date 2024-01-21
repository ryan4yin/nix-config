{pkgs, ...}:
pkgs.stdenvNoCC.mkDerivation {
  name = "brcm-firmware";
  nativeBuildInputs = with pkgs; [gnutar xz];
  buildCommand = ''
    dir="$out/lib/"
    mkdir -p "$dir"
    tar -axvf ${./firmware.tar.xz} -C "$dir"
  '';
}

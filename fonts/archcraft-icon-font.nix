{ lib, stdenvNoCC, fetchgit }:

stdenvNoCC.mkDerivation rec {
  pname = "archcraft-font";
  version = "2023-05-07";

  src = fetchgit {
    url = "https://github.com/archcraft-os/archcraft-packages.git";
    rev = "88030ee6d2df80db958541b53bd3673e081720cf";  # git commit id
    sparseCheckout = [ "archcraft-fonts/files/icon-fonts/archcraft.ttf" ];  # only fetch the feather.ttf file

    # the sha256 is used to verify the integrity of the downloaded source, and alse cache the build result.
    # so if you copy other package src's sha256, you will get a cached build result of that package, and all configs in this file will be ignored.
    # specify sha256 to empty and build it, then an error will indicate the correct sha256
    sha256 = "sha256-DrGN8lN4Yr1RTyCUZhJjzKgCuC0vTnSWjOKovNg3T/U="; 
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 archcraft-fonts/files/icon-fonts/archcraft.ttf -t $out/share/fonts/truetype/

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/archcraft-os/archcraft-packages";
    description = "Archcraft icon font";
    version = version;
    longDescription = ''Archcraft icon font'';
    license = licenses.mit;
    maintainers = [ maintainers.ryan4yin ];
    platforms = platforms.all;
  };
}
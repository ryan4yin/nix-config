{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  libxkbcommon,
  xorg,
}:
let
  version = "0.24.0";

  # Prebuilt release binary; the crate is not packaged in nixpkgs.
  asset = {
    url = "https://github.com/trycua/cua/releases/download/cua-driver-rs-v${version}/cua-driver-rs-${version}-linux-x86_64-binary.tar.gz";
    hash = "sha256-s7j/Ullf6xESGaoKyQ47NmGMxoaqggWu1PPn4aZ8e2Q=";
  };
in
stdenv.mkDerivation {
  pname = "cua-driver";
  inherit version;

  src = fetchurl asset;

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    stdenv.cc.cc.lib
    xorg.libX11
    xorg.libXi
    libxkbcommon
  ];

  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 cua-driver $out/bin/cua-driver
    install -Dm755 cua-cursor-theme $out/lib/cua-driver/cua-cursor-theme
    install -Dm755 libcua_driver_sdk.so $out/lib/cua-driver/libcua_driver_sdk.so
    install -Dm755 cua_driver_node_runtime.node $out/lib/cua-driver/cua_driver_node_runtime.node
    install -Dm644 cua_driver_abi.h $out/include/cua-driver/cua_driver_abi.h
    mkdir -p $out/share/cua-driver
    cp -r wayland-helper $out/share/cua-driver/wayland-helper
    runHook postInstall
  '';

  meta = {
    description = "Desktop-automation driver for computer-use agents (MCP/CLI)";
    homepage = "https://github.com/trycua/cua";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "cua-driver";
  };
}

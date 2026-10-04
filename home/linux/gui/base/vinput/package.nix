{
  inputs,
  pkgs,
  pkgs-patched,
  backend,
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  sherpaOnnx = inputs.fcitx5-vinput.inputs.sherpa-onnx.packages.${system}.sherpa-onnx;
  vinput = inputs.fcitx5-vinput.packages.${system}.fcitx5-vinput;
in
if backend == "openvino" then
  let
    sherpaOnnxOpenVino = pkgs-patched.sherpa-onnx;
  in
  vinput.overrideAttrs (old: {
    buildInputs = map (
      dependency: if dependency == sherpaOnnx then sherpaOnnxOpenVino else dependency
    ) old.buildInputs;
    passthru = (old.passthru or { }) // {
      sherpaOnnxVersion = sherpaOnnxOpenVino.version;
    };
  })
else
  vinput

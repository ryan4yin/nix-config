# 为了不使用默认的 rime-data，改用小鹤音形数据，这里需要 override
# 参考 https://github.com/NixOS/nixpkgs/blob/e4246ae1e7f78b7087dce9c9da10d28d3725025f/pkgs/tools/inputmethods/fcitx5/fcitx5-rime.nix
{ inputs, ... }:
(
  _: super:
  let
    # 小鹤音形 schema 数据，来自 nur-ryan4yin 的 rime-data-flypy，
    # 再叠加我自己的用户词库 flypy_user.txt。
    rime-data-flypy = inputs.nur-ryan4yin.packages.${super.stdenv.hostPlatform.system}.rime-data-flypy;

    rime-data = super.runCommandLocal "rime-data-flypy-custom" { } ''
      mkdir -p $out/share/rime-data
      cp -r ${rime-data-flypy}/share/rime-data/. $out/share/rime-data/
      chmod -R u+w $out/share/rime-data
      cp ${./flypy_user.txt} $out/share/rime-data/flypy_user.txt
    '';
  in
  {
    inherit rime-data;
    fcitx5-rime = super.fcitx5-rime.override { rimeDataPkgs = [ rime-data ]; };

    # used by macOS Squirrel
    flypy-squirrel = rime-data;
  }
)

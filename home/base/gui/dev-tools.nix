{
  pkgs,
  lib,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      qrtool # decode/encode qr code
    ]
    # mitmproxy & wireshark don't build on darwin
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      mitmproxy # http/https proxy tool
      wireshark # network analyzer
    ];
}

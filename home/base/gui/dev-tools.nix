{
  pkgs,
  nur-ryan4yin,
  ...
}: {
  home.packages = with pkgs; [
    mitmproxy # http/https proxy tool
    insomnia # REST client
    wireshark # network analyzer

    # IDEs
    # jetbrains.idea-community

    nur-ryan4yin.packages.${pkgs.system}.gemini-cli
  ];
}

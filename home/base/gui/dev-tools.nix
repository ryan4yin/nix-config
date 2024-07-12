{pkgs, ...}: {
  home.packages = with pkgs; [
    mitmproxy # http/https proxy tool
    insomnia # REST client
    wireshark # network analyzer

    # IDEs
    jetbrains.idea-community
  ];
}

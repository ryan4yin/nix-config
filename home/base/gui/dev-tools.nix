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

    # AI cli tools
    nur-ryan4yin.packages.${pkgs.system}.gemini-cli
    k8sgpt
    kubectl-ai # an ai helper opensourced by google
  ];
}

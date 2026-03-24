{ pkgs, pkgs-master, ... }:
{
  home.packages =
    with pkgs;
    [
      mitmproxy # http/https proxy tool
      wireshark # network analyzer
    ]
    # AI Agent Tools
    ++ (with pkgs-master; [
      codex
      cursor-cli
      claude-code
      gemini-cli
      opencode
    ]);
}

{ pkgs, llm-agents, ... }:
{
  home.packages =
    with pkgs;
    [
      mitmproxy # http/https proxy tool
      wireshark # network analyzer
    ]
    # AI Agent Tools
    ++ (with llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      # Agents
      codex
      cursor-cli
      claude-code
      gemini-cli
      opencode

      # Utilities
      rtk # CLI proxy that reduces LLM token consumption
    ]);
}

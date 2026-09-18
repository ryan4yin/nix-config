{ pkgs, llm-agents, ... }:
{
  home.packages =
    with pkgs;
    [
      mitmproxy # http/https proxy tool
      wireshark # network analyzer
      qrtool # decode/encode qr code
    ]
    # AI Agent Tools
    ++ (with llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      # Agents
      codex
      cursor-cli
      opencode
      kimi-code

      # Utilities
      rtk # CLI proxy that reduces LLM token consumption
    ]);
}

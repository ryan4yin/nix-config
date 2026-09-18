{ pkgs, llm-agents, ... }:
let
  agentPackages = llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [ ../codex.nix ];

  home.packages =
    with pkgs;
    [
      mitmproxy # http/https proxy tool
      wireshark # network analyzer
      qrtool # decode/encode qr code
    ]
    # AI Agent Tools
    ++ [
      # Agents
      agentPackages.opencode
      agentPackages.kimi-code
      agentPackages.pi
      agentPackages.omp
      agentPackages.crush

      # Utilities
      agentPackages.rtk # CLI proxy that reduces LLM token consumption
    ];
}

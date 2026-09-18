{ pkgs, llm-agents, ... }:
let
  agentPackages = llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  codexNoAnalytics = pkgs.writeShellApplication {
    name = "codex";
    text = ''
      exec ${agentPackages.codex}/bin/codex \
        --config analytics.enabled=false \
        --config feedback.enabled=false \
        --config check_for_update_on_startup=false \
        "$@"
    '';
  };
in
{
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
      codexNoAnalytics
      agentPackages.cursor-agent
      agentPackages.opencode
      agentPackages.kimi-code
      agentPackages.pi
      agentPackages.omp
      agentPackages.crush

      # Utilities
      agentPackages.rtk # CLI proxy that reduces LLM token consumption
    ];
}

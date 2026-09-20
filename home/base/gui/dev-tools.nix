{
  pkgs,
  lib,
  llm-agents,
  ...
}:
let
  agentPackages = llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages =
    with pkgs;
    [
      qrtool # decode/encode qr code
    ]
    # mitmproxy & wireshark don't build on darwin
    # (removed there, see modules/darwin/broken-packages.nix)
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      mitmproxy # http/https proxy tool
      wireshark # network analyzer
    ]
    # AI Agent Tools
    ++ [
      # Agents
      agentPackages.codex
      agentPackages.opencode
      agentPackages.kimi-code
      agentPackages.pi
      agentPackages.omp
      agentPackages.crush
    ];
}

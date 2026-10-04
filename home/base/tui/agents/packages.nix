{
  pkgs,
  llm-agents,
  nur-ryan4yin,
  ...
}:
let
  agentPackages = llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages = [
    # Agents
    agentPackages.codex
    agentPackages.opencode2
    agentPackages.pi
    # dsh from nur-packages: llm-agents.nix's dsh cannot boot on nixpkgs node
    # (node-addon-require-builtin probe), this one shims it.
    nur-ryan4yin.packages.${pkgs.stdenv.hostPlatform.system}.dsh

    # MCP servers, configured project-scoped in opencode.jsonc / .codex/config.toml
    pkgs.mcp-grafana
  ];
}

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
    # (node-addon-require-builtin probe), this one shims it. The Nushell-only
    # plugin rides in through the package's withPlugins wrapper.
    (nur-ryan4yin.packages.${pkgs.stdenv.hostPlatform.system}.dsh.withPlugins [
      nur-ryan4yin.packages.${pkgs.stdenv.hostPlatform.system}.dsh-nushell-only
    ])

    # Docs lookup CLI behind the find-docs skill (agents/skills/find-docs). The skill's flags are
    # written against this package, not against upstream's npx instructions.
    pkgs.ctx7

    # MCP servers, configured project-scoped in opencode.jsonc / .codex/config.toml
    pkgs.mcp-grafana
  ];
}

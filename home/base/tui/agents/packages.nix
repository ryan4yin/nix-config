{
  pkgs,
  llm-agents,
  ...
}:
let
  agentPackages = llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  # llm-agents.nix still exposes OpenCode V2 as `opencode2` so it can coexist
  # with the v1 package. Re-expose its binary under the normal command name.
  opencode = pkgs.linkFarm "opencode" [
    {
      name = "bin/opencode";
      path = "${agentPackages.opencode2}/bin/opencode2";
    }
  ];
in
{
  home.packages = [
    # Agents
    agentPackages.codex
    opencode
    agentPackages.pi
    # dsh from nur-packages: llm-agents.nix's dsh cannot boot on nixpkgs node
    # (node-addon-require-builtin probe), this one shims it.
    pkgs.dsh

    # Docs lookup CLI behind the find-docs skill (agents/skills/find-docs). The skill's flags are
    # written against this package, not against upstream's npx instructions.
    pkgs.ctx7

    # MCP servers, configured project-scoped in opencode.jsonc / .codex/config.toml
    pkgs.mcp-grafana
  ];
}

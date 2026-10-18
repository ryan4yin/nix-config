{
  pkgs,
  llm-agents,
  myNurPkgs,
  dsh-nu,
  ...
}:
let
  agentPackages = llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  # dsh-nu's flake builds the plugin from its own checkout; this repository
  # supplies the dsh installation it plugs into.
  dshNu = dsh-nu.lib.mkDshNuPackage {
    inherit pkgs;
    dsh = myNurPkgs.dsh;
  };
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
    (myNurPkgs.dsh.withPlugins [ dshNu ])

    # Docs lookup CLI behind the find-docs skill (agents/skills/find-docs). The skill's flags are
    # written against this package, not against upstream's npx instructions.
    pkgs.ctx7

    # MCP servers, configured project-scoped in opencode.jsonc / .codex/config.toml
    pkgs.mcp-grafana
  ];
}

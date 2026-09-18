{
  config,
  lib,
  pkgs,
  llm-agents,
  ...
}:
let
  configFile = "${config.home.homeDirectory}/.codex/config.toml";
in
{
  home.packages = [ llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex ];

  home.activation.configureCodexPrivacy = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.nushell}/bin/nu ${./codex-privacy.nu} ${lib.escapeShellArg configFile} ${lib.escapeShellArg "${pkgs.yq-go}/bin/yq"}
  '';
}

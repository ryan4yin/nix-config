{ config, ... }:
let
  # The global rules are edited often, so link them out-of-store: an edit reaches
  # the next agent session without a Home Manager switch. Same rationale as
  # `home/base/tui/tuios`; the checkout path is hardcoded, like the repo's other
  # out-of-store links.
  rules = "${config.home.homeDirectory}/nix-config/agents/AGENTS.md";
  link = config.lib.file.mkOutOfStoreSymlink rules;
in
{
  # One canonical rules file, projected into every agent's config location.
  home.file = {
    ".codex/AGENTS.md".source = link; # Codex
    ".pi/agent/AGENTS.md".source = link; # Pi
    ".agents/AGENTS.md".source = link; # cross-tool
  };

  xdg.configFile."opencode/AGENTS.md".source = link; # OpenCode
}

{ config, ... }:
let
  # The global rules are edited often, so link them out-of-store: an edit reaches
  # the next agent session without a Home Manager switch. Same rationale as
  # `home/base/tui/tuios`; the checkout path is hardcoded, like the repo's other
  # out-of-store links. The source is not named AGENTS.md, so agents working in
  # this checkout do not load it a second time as nested instructions for agents/.
  rules = "${config.home.homeDirectory}/nix-config/agents/global-rules.md";
  link = config.lib.file.mkOutOfStoreSymlink rules;
in
{
  # One canonical rules file, projected into every agent's config location.
  home.file = {
    ".codex/AGENTS.md".source = link; # Codex
    ".pi/agent/AGENTS.md".source = link; # Pi
    ".agents/AGENTS.md".source = link; # cross-tool; dsh's `$DSH_AGENTS_HOME` from 0.2.1-alpha.2
    ".dsh/AGENTS.md".source = link; # dsh's `$DSH_HOME`, its only global scope before that
  };

  xdg.configFile."opencode/AGENTS.md".source = link; # OpenCode
}

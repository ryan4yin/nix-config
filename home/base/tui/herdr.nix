{
  pkgs,
  lib,
  llm-agents,
  ...
}:
{
  programs.herdr = {
    enable = true;
    package = llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr;

    settings = {
      onboarding = false;

      update = {
        version_check = false;
        manifest_check = false;
      };

      # home-manager owns ~/.ssh/config; keep herdr from writing it too.
      remote.manage_ssh_config = false;

      # "catppuccin" is the mocha flavor, matching catppuccin-nix's fixed flavor.
      theme.name = "catppuccin";

      terminal = {
        default_shell = lib.getExe pkgs.nushell;
        shell_mode = "auto";
        new_cwd = "follow";
      };

      ui = {
        agent_panel_sort = "priority";
        prompt_new_tab_name = false;
        sound.enabled = false;
      };

      session.resume_agents_on_restore = true;
      experimental.kitty_graphics = true;
    };
  };
}

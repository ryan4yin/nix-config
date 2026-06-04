{ lib, ... }:
{
  catppuccin.zed.enable = true;

  programs.zed-editor = {
    enable = true;
    mutableUserSettings = true;

    userSettings = {
      # Editor behavior
      autosave = "on_focus_change";
      inlay_hints.enabled = true;
      soft_wrap = "editor_width";
      which_key.enabled = true;

      # Modal editing
      helix_mode = true;
      vim = {
        use_smartcase_find = true;
        toggle_relative_line_numbers = true;
      };

      # Font sizing
      ui_font_size = lib.mkDefault 16.0;
      buffer_font_size = lib.mkDefault 14.0;
      agent_ui_font_size = lib.mkDefault 16.0;
      agent_buffer_font_size = lib.mkDefault 15.0;

      # App behavior
      auto_update = false;

      # AI/editor integrations
      agent.play_sound_when_agent_done = "when_hidden";
      agent_servers = {
        opencode.type = "registry";
        cursor.type = "registry";
        codex-acp.type = "registry";
        claude-acp.type = "registry";
      };

      # Privacy
      edit_predictions.allow_data_collection = "no";
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
    };

    extensions = [
      "catppuccin"
      "dockerfile"
      "just"
      "nix"
      "nu"
      "terraform"
      "toml"
    ];
  };
}

{ lib, ... }:
{
  catppuccin.zed.enable = true;

  programs.zed-editor = {
    enable = true;
    mutableUserSettings = true;

    userSettings = {
      # Language-specific settings
      languages = {
        Python = {
          formatter.language_server.name = "ruff";
          language_servers = [
            "ty"
            "ruff"
            "!basedpyright"
            "!pyrefly"
            "!pyright"
            "!pylsp"
          ];
        };
        Rust = {
          hard_tabs = false;
          formatter.language_server.name = "rust-analyzer";
          language_servers = [
            "rust-analyzer"
            "!rustc"
          ];
        };
        Go = {
          formatter.language_server.name = "gopls";
          language_servers = [
            "gopls"
            "!goimports"
          ];
        };
      };

      # Terminal
      terminal.shell.with_arguments = {
        program = "bash";
        args = [
          "--login"
          "-c"
          "nu --login --interactive"
        ];
      };

      # Editor behavior
      auto_signature_help = true;
      autosave = "on_focus_change";
      code_lens = "on";
      completion_menu_item_kind = "symbol";
      completions.lsp_fetch_timeout_ms = 2000;
      diagnostics.inline.enabled = true;
      document_folding_ranges = "off";
      inlay_hints.enabled = true;
      minimap.show = "auto";
      relative_line_numbers = "enabled";
      semantic_tokens = "combined";
      soft_wrap = "editor_width";
      vertical_scroll_margin = 5.0;
      which_key.enabled = true;
      indent_guides = {
        background_coloring = "indent_aware";
        coloring = "indent_aware";
      };

      # Search
      search.regex = true;
      use_smartcase_search = true;

      # Formatting
      prettier.allowed = true;

      # UI chrome
      tabs = {
        file_icons = true;
        git_status = true;
      };
      title_bar = {
        show_branch_status_icon = true;
        show_menus = false;
        show_user_menu = true;
      };

      # Git
      git.inline_blame.show_commit_summary = true;

      # Modal editing
      helix_mode = true;
      vim = {
        use_smartcase_find = true;
        toggle_relative_line_numbers = true;
      };

      # Fonts
      ui_font_family = lib.mkDefault "LXGW WenKai Screen";
      ui_font_size = lib.mkDefault 16.0;
      buffer_font_family = lib.mkDefault "Maple Mono NF CN";
      buffer_font_size = lib.mkDefault 14.0;
      agent_ui_font_size = lib.mkDefault 16.0;
      agent_buffer_font_size = lib.mkDefault 15.0;

      # App behavior
      auto_update = false;
      cli_default_open_behavior = "existing_window";

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

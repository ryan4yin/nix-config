{
  home.sessionVariables = {
    KIMI_DISABLE_TELEMETRY = "1";

    PI_TELEMETRY = "0";
    PI_SKIP_VERSION_CHECK = "1";

    OPENCODE_DISABLE_AUTOUPDATE = "1";
  };

  # home.sessionVariables wraps every value in double quotes without escaping
  # them (home-manager's lib.shell.export), which turns JSON like
  # {"share":"disabled"} into the shell word {share:disabled}. Emit the export
  # by hand so the quotes survive.
  home.sessionVariablesExtra = ''
    export OPENCODE_CONFIG_CONTENT='{"share":"disabled"}'
  '';
}

{
  home.sessionVariables = {
    DO_NOT_TRACK = "1";

    KIMI_DISABLE_TELEMETRY = "1";

    PI_TELEMETRY = "0";
    PI_SKIP_VERSION_CHECK = "1";

    CRUSH_DISABLE_METRICS = "1";
    CRUSH_DISABLE_PROVIDER_AUTO_UPDATE = "1";

    OPENCODE_CONFIG_CONTENT = builtins.toJSON {
      share = "disabled";
    };
    OPENCODE_DISABLE_AUTOUPDATE = "1";
  };
}

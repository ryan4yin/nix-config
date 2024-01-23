{
  config,
  lib,
  username,
  ...
}: let
  homeDir = config.users.users."${username}".home;
in {
  services.yabai = {
    enable = true;

    # Whether to enable yabai's scripting-addition.
    # SIP must be disabled for this to work.
    # https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection
    enableScriptingAddition = true;
    # config = {};
    extraConfig = builtins.readFile ./yabairc;
  };

  # custom log path for debugging
  launchd.user.agents.yabai.serviceConfig = {
    StandardErrorPath = "${homeDir}/Library/Logs/yabai.stderr.log";
    StandardOutPath = "${homeDir}/Library/Logs/yabai.stdout.log";
  };

  launchd.daemons.yabai-sa = {
    # https://github.com/koekeishiya/yabai/issues/1287
    script = lib.mkForce ''
      echo "skip it"
    '';
  };
}

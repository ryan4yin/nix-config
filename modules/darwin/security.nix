{
  config,
  myvars,
  ...
}: let
  homeDir = config.users.users."${myvars.username}".home;
in {
  # https://github.com/LnL7/nix-darwin/blob/master/modules/programs/gnupg.nix
  # try `pkill gpg-agent` if you have issues(such as `no pinentry`)
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };

  # enable logs for debugging
  launchd.user.agents.gnupg-agent.serviceConfig = {
    StandardErrorPath = "${homeDir}/Library/Logs/gnupg-agent.stderr.log";
    StandardOutPath = "${homeDir}/Library/Logs/gnupg-agent.stdout.log";
  };

  # Disable password authentication for SSH
  environment.etc."ssh/sshd_config.d/200-disable-password-auth.conf".text = ''
    PasswordAuthentication no
    KbdInteractiveAuthentication no
  '';
}

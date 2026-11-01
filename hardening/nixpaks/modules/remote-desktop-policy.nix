# Shared policy for graphical remote-desktop clients. No raw camera, video or
# PipeWire access; SSH tunnels use the user's agent socket explicitly.
{
  config,
  lib,
  sloth,
  ...
}:
let
  cfg = config.remoteDesktop;
in
{
  imports = [
    ./desktop-base.nix
    ./network.nix
  ];
  options.remoteDesktop.sshAgent = lib.mkEnableOption "the user's SSH agent and SSH client config";
  config = {
    pasta.mode = "isolate";
    portalGroups = {
      fileChooser = true;
      openUri = true;
      notifications = true;
      inputMethod = true;
    };
    desktopIntegration = {
      notifications = true;
      accessibility = true;
    };
    bubblewrap = {
      sockets.pulse = true;
      bind.rw = [
        (sloth.mkdir (sloth.concat' sloth.homeDir "/.config/remmina"))
        (sloth.mkdir (sloth.concat' sloth.homeDir "/.local/share/remmina"))
        (sloth.mkdir (sloth.concat' sloth.homeDir "/.remmina"))
        sloth.xdgDownloadDir
      ];
      bind.ro = lib.optionals cfg.sshAgent [
        (sloth.concat' sloth.homeDir "/.ssh/config")
        (sloth.concat' sloth.homeDir "/.ssh/known_hosts")
        (sloth.concat' sloth.runtimeDir "/ssh-agent")
      ];
      env = lib.optionalAttrs cfg.sshAgent {
        SSH_AUTH_SOCK = sloth.concat' sloth.runtimeDir "/ssh-agent";
      };
    };
  };
}

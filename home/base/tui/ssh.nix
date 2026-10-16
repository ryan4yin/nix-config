{
  config,
  lib,
  pkgs,
  mysecrets,
  myvars,
  ...
}:
let
  # WA-035: settings for the home LAN, which the desktop reaches over a Mesh
  # WiFi backhaul.
  lanHost = {
    # A lost first SYN must not fail the connection; a LAN handshake is ~2 ms,
    # so the connect is cut short and retried instead of hanging.
    ConnectTimeout = 1;
    ConnectionAttempts = 3;
    # One persistent master per host keeps a session (and with it the mesh's
    # forwarding entry for that peer) open, so later connections reuse it
    # instead of resolving and handshaking again. Three missed keepalives reap a
    # master whose path died.
    ControlMaster = "auto";
    ControlPersist = "30m";
    ServerAliveInterval = 15;
  };
in
{
  home.file.".ssh/romantic.pub".source = "${mysecrets}/public/romantic.pub";

  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;
    # Keep this one definition: Nix merges a `settings."<pattern>"` attribute
    # path into `settings = ...` only while that value stays an attrset literal,
    # so the generated LAN patterns are merged inside it with `//` instead.
    settings = {
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "yes";
        Compression = true;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };

      "github.com" = {
        # WA-028: pinned to IPv4 until the mihomo v6 fake-ip pool is proven here
        AddressFamily = "inet";
        HostName = "ssh.github.com";
        Port = 443;
        User = "git";
        IdentitiesOnly = true;
      };

      "192.168.*" = {
        ForwardAgent = true;
      }
      // lanHost;
    }
    // lib.genAttrs (builtins.attrNames myvars.networking.hostsAddr) (_: lanHost);
  };

  # Keep ~/.ssh/config a real, user-owned file rather than a /nix/store symlink.
  #
  # OpenSSH accepts a config owned by root or the invoking user, but
  # bubblewrap-based sandboxes (`--unshare-user`) expose root-owned store files
  # as `nobody`, which trips the check (`Bad owner or permissions`).  Disabling
  # the home.file entry keeps Home Manager's linker out of the way; `install`
  # writes a fresh 0600 copy on each activation.
  #
  # Linux only: macOS' Seatbelt sandbox keeps store ownership intact, so the
  # normal symlink is fine there.
  home.file.".ssh/config".enable = lib.mkIf pkgs.stdenv.hostPlatform.isLinux false;
  home.activation.sshConfigRegularFile = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run install -D -m 600 ${config.home.file.".ssh/config".source} "$HOME/.ssh/config"
    ''
  );
}

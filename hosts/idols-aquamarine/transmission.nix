{
  config,
  myvars,
  ...
}: let
  dataDir = "/data/fileshare/public/transmission";
  name = "transmission";
in {
  # the headless Transmission BitTorrent daemon
  # https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/services/torrent/transmission.nix
  # https://wiki.archlinux.org/title/transmission
  services.transmission = {
    enable = true;
    user = name;
    group = name;
    home = dataDir;
    downloadDirPermissions = "0770";

    # Whether to enable tweaking of kernel parameters to open many more connections at the same time.
    # Note that you may also want to increase peer-limit-global.
    # And be aware that these settings are quite aggressive and might not suite your regular desktop use.
    # For instance, SSH sessions may time out more easily.
    performanceNetParameters = true;

    # Path to a JSON file to be merged with the settings.
    # Useful to merge a file which is better kept out of the Nix store to set secret config parameters like `rpc-password`.
    credentialsFile = config.age.secrets."transmission-credentials.json".path;

    # Whether to open the RPC port in the firewall.
    openRPCPort = false;
    openPeerPorts = true;

    # https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md
    settings = {
      # 0 = None, 1 = Critical, 2 = Error, 3 = Warn, 4 = Info, 5 = Debug, 6 = Trace;
      message-level = 3;

      # Encryption may help get around some ISP filtering,
      # but at the cost of slightly higher CPU use.
      # 0 = Prefer unencrypted connections,
      # 1 = Prefer encrypted connections,
      # 2 = Require encrypted connections; default = 1)
      encryption = 2;

      # rpc = Web Interface
      rpc-port = 9091;
      rpc-bind-address = "127.0.0.1";
      anti-brute-force-enabled = true;
      # After this amount of failed authentication attempts is surpassed,
      # the RPC server will deny any further authentication attempts until it is restarted.
      # This is not tracked per IP but in total.
      anti-brute-force-threshold = 20;
      rpc-authentication-required = true;

      # Comma-delimited list of IP addresses.
      # Wildcards allowed using '*'. Example: "127.0.0.*,192.168.*.*",
      rpc-whitelist-enabled = true;
      rpc-whitelist = "127.0.0.*,192.168.*.*";
      # Comma-delimited list of domain names.
      # Wildcards allowed using '*'. Example: "*.foo.org,example.com",
      rpc-host-whitelist-enabled = true;
      rpc-host-whitelist = "*.writefor.fun,localhost,192.168.5.*";
      rpc-user = myvars.username;
      rpc-username = myvars.username;
      # rpc-password = "test"; # you'd better use the credentialsFile for this.

      incomplete-dir-enabled = true;
      incomplete-dir = "${dataDir}/incomplete";
      download-dir = "${dataDir}/downloads";

      # Watch a directory for torrent files and add them to transmission.
      watch-dir-enabled = false;
      watch-dir = "${dataDir}/watch";
      # Whether to enable Micro Transport Protocol (µTP).
      utp-enabled = true;
      # Executable to be run at torrent completion.
      script-torrent-done-enabled = false;
      # script-torrent-done-filename = "/path/to/script";

      # Enable Local Peer Discovery (LPD).
      lpd-enabled = true;
      # The peer port to listen for incoming connections.
      peer-port = 51413;
      # Enable UOnP or NAT-PMP to forward a port through your firewall(NAT).
      # https://github.com/transmission/transmission/blob/main/docs/Port-Forwarding-Guide.md
      port-forwarding-enabled = true;

      # "normal" speed limits
      speed-limit-down-enabled = true;
      speed-limit-down = 30000; # KB/s
      speed-limit-up-enabled = true;
      speed-limit-up = 500; # KB/s
      upload-slots-per-torrent = 8;

      # Start torrents as soon as they are added
      start-added-torrents = true;

      # Queuing
      # When true, Transmission will only download
      # download-queue-size non-stalled torrents at once.
      download-queue-enabled = true;
      download-queue-size = 5;

      # When true, torrents that have not shared data for
      # queue-stalled-minutes are treated as 'stalled'
      # and are not counted against the queue-download-size
      # and seed-queue-size limits.
      queue-stalled-enabled = true;
      queue-stalled-minutes = 60;

      # When true. Transmission will only seed seed-queue-size
      # non-stalled torrents at once.
      seed-queue-enabled = true;
      seed-queue-size = 10;
    };
  };
}

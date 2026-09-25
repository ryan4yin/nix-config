# Youko - Homelab Services

Storage, operation and maintenance related services are running on this host (migrated here from the
retired `idols-aquamarine` guest):

1. Storage such as a git server, file server, torrent downloader, etc.
1. Back up my personal data with restic; the data is encrypted on the client.
1. Collect and monitor the metrics of my homelab.

## Features

Services:

1. caddy: Reverse proxy / TLS front end and the `file.writefor.fun` file server.
1. gitea: Self-hosted git service.
1. sftpgo: SFTP / WebDAV server.
1. transmission: BitTorrent client.
1. postgresql: Database for the homelab services.
1. v2ray: HTTP/SOCKS proxy for the homelab.
1. restic: Encrypted backups; hosts the REST server the desktops push to.
1. victoriametrics + vmalert + alertmanager + grafana: Monitor the metrics of my homelab.
1. homepage + uptime-kuma: Service dashboard and uptime checks.

All the services assumes a reverse proxy to be setup in the front, they are all listening on
localhost, and a caddy service is listening on the local network interface and proxy the requests to
the services.

## TODO

- transmission has no reachable inbound port: youko's default gateway is `suzi` (192.168.5.178,
  mihomo transparent proxy, no UPnP/NAT-PMP) and its traffic is proxied, so
  `port-forwarding-enabled` never maps 51413. Fix by routing transmission **direct** and using its
  public IPv6 (or a static v4 port-forward on the main router, or a port-forwarding VPN).

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

All the services assume a reverse proxy in front: they listen on localhost, and a caddy service
listens on the local network interface and proxies requests to them. The exception is transmission,
which runs in its own network namespace and binds its RPC to `192.168.5.118`.

## transmission networking

transmission deliberately does not use the host's default gateway `suzi` (192.168.5.178): it is a
mihomo transparent proxy that hijacks DNS to fake IPs (only routable through the proxy) and has no
UPnP/NAT-PMP, so a proxied transmission can never accept inbound peers.

Instead the service runs in its own network namespace, with a veth on `br0`, the address
`192.168.5.118`, a default route at the main router (`192.168.5.1`), a real resolver, and a fixed
MAC for a stable IPv6 IID. It listens on `192.168.5.118:51413` (TCP/UDP and IPv6) and caddy reaches
its RPC at `192.168.5.118:9091`. See `transmission.nix` for the implementation.

## TODO

- Forward `51413/tcp+udp` to `192.168.5.118` on the main router, or enable UPnP there. NAT-PMP and
  UPnP now target the main router, which is reachable from the namespace.

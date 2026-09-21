# Idols - Aquamarine

Storage, operation and maintenance related services are running on this host:

1. Storage such as git server, file server/browser, torrent downloader,, etc.
1. Backup or sync my personal data to cloud or NAS.
   - For safety, those data should be encrypted before sending to the cloud or my NAS.
1. Collect and monitor the metrics/logs of my homelab.

## Features

Services:

1. prometheus + alertmanager + grafana + loki: Monitor the metrics/logs of my homelab.
1. restic: Backup my personal data to cloud or NAS.
1. synthing: Sync file between android/macbook/PC and NAS.
1. gitea: Self-hosted git service.
1. sftpgo: SFTP server.
1. transmission & AriaNg: Torrent downloader and HTTP downloader
1. alist/filebrower: File browser for local/SMB/Cloud

All the services assumes a reverse proxy to be setup in the front, they are all listening on
localhost, and a caddy service is listening on the local network interface and proxy the requests to
the services.

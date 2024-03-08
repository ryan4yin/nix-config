# Idols - Kana

Host running some common applications, such as hompage, file browser, torrent downloader, etc.

All the services assumes a reverse proxy to be setup in the front, they are all listening on localhost,
and a caddy service is listening on the local network interface and proxy the requests to the services.

## Services

1. dashy: Homepage
1. ddns
1. transmission & AriaNg: Torrent downloader and HTTP downloader
1. uptime-kuma: uptime monitoring
1. alist/filebrower: File browser for local/SMB/Cloud
1. excalidraw/DDTV/owncast/jitsi-meet/...


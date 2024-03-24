# Dae - NixOS Router

A router(IPv4 only) with a transparent proxy to bypass the G|F|W.

NOTE: dae do not provides a http/socks5 proxy server, so a v2ray server is running on
[idols_kana](../idols_kana/proxy.nix) to provides a http/socks5 proxy service.

## Troubleshooting

### Can not access the global internet

1. Check whether the subscription url is accessible.
   - If not, then you need to get a new subscription url and update the `dae`'s configuration.
1. Check the `dae` service's log by `journalctl -u dae -n 1000`.

### DNS cannot be resolved

1. `sudo systemctl stop dae`, then try to resolve the domain name again.
   - If it works, the problem is caused by `dae` service.
   - check dae's log by `journalctl -u dae -n 1000`
1. DNS & DHCP is provided by `dnsmasq` service, check the configuration of `dnsmasq`.

### DHCP cannot be obtained

1. `ss -tunlp`, check if `dnsmasq` is running and listening on udp port 67.
1. `journalctl -u dnsmasq -n 1000` to check the log of `dnsmasq`.
1. Request a new IP address by disconnect and reconnect one of your devices' wifi.
1. `nix shell nixpkgs#dhcpdump` and then `sudo dhcpdump -i br-lan`, check if the DHCP request is
   received by `dnsmasq`.
   1. The server listens on UDP port number 67, and the client listens on UDP port number 68.
   1. DHCP operations fall into four phases:
      1. Server **discovery**: The DHCP client broadcasts a DHCPDISCOVER message on the network
         subnet using the destination address 255.255.255.255 (limited broadcast) or the specific
         subnet broadcast address (directed broadcast).
      1. IP lease **offer**: When a DHCP server receives a DHCPDISCOVER message from a client, which
         is an IP address lease request, the DHCP server reserves an IP address for the client and
         makes a lease offer by sending a DHCPOFFER message to the client.
      1. IP lease **request**: In response to the DHCP offer, the client replies with a DHCPREQUEST
         message, broadcast to the server,[a] requesting the offered address.
      1. IP lease **acknowledgement**: When the DHCP server receives the DHCPREQUEST message from
         the client, it sends a DHCPACK packet to the client, which includes the lease duration and
         any other configuration information that the client might have requested.
   1. So if you see only `DISCOVER` messages, the dhsmasq is not working properly.

## References

- <https://github.com/ghostbuster91/blogposts/blob/main/router2023-part2/main.md>
- <https://github.com/ghostbuster91/nixos-router>

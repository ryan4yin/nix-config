# Idols - Aquamarine

Use aqua as a passby router(IPv4 only) to access the global internet.


## Troubleshooting

### DNS cannot be resolved

1. `sudo systemctl stop dae`, then try to resolve the domain name again.
   - If it works, the problem is caused by `dae` service.
   - check dae's log by `sudo journalctl -u dae`
1. DNS & DHCP is provided by `dnsmasq` service, check the configuration of `dnsmasq`.


## References

- <https://github.com/ghostbuster91/blogposts/blob/main/router2023-part2/main.md>
- <https://github.com/ghostbuster91/nixos-router>



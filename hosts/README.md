# Hosts

1. `harmonica`: My MacBook Pro 2020 13-inch, for work.
2. `idols`
   1. `ai`: My main computer, with NixOS + I5-13600KF + RTX 4090 GPU, for gaming & daily use.
   2. `aquamarine`: My NixOS virtual machine with R9-5900HX(8C16T), for distributed building & testing.
   3. `kana`: Yet another NixOS vm on another physical machine with R5-5625U(6C12T).
   4. `ruby`: Another NixOS vm on another physical machine with R7-5825U(8C16T).
3. `rolling_girls`: My RISCV64 hosts.
   1. `nozomi`: Lichee Pi 4A, TH1520(4xC910@2.0G), 8GB RAM + 32G eMMC + 64G SD Card.
   2. `yukina`: Lichee Pi 4A(Internal Test Version), TH1520(4xC910@2.0G), 8GB RAM + 8G eMMC + 128G SD Card.
   3. `chiaya`: Milk-V Mars, JH7110(4xU74@1.5 GHz), 4G RAM + No eMMC + 64G SD Card.

# idols - Oshi no Ko

These four servers are named after the four main characters of the mange/anime Oshi no Ko, they form a NixOS distributed building cluster,
I usually run the build command on `Ai` and nix will distribute the build to other three machines, which is convenient and fast.

When building some packages for riscv64 or aarch64, I often have no cache available because of various changes under the hood, so I need to build much more packages than usual, which is one of the reasons why the cluster was originally built, and another reason is distributed building is cool!

![](/_img/nix-distributed-building.webp)

![](/_img/nix-distributed-building-log.webp)

## References

![](/_img/idols-famaily.webp)
![](/_img/idols-ai.webp)

See [Oshi no Ko 【推しの子】 - Wikipedia](https://en.wikipedia.org/wiki/Oshi_no_Ko) for more information.


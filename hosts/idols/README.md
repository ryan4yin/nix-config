# Oshi no Ko

These four servers are named after the four main characters of the mange/anime Oshi no Ko, they form a NixOS distributed building cluster,
I usually run the build command on `Ai` and nix will distribute the build to other three machines, which is convenient and fast.

When building some packages for riscv64 or aarch64, I often have no cache available because of various changes under the hood, so I need to build much more packages than usual, which is one of the reasons why the cluster was originally built, and another reason is distributed building is cool!

![](/_img/nix-distributed-building.webp)

![](/_img/nix-distributed-building-log.webp)

## References

![](/_img/idols-famaily.webp)
![](/_img/idols-ai.webp)

See [Oshi no Ko 【推しの子】 - Wikipedia](https://en.wikipedia.org/wiki/Oshi_no_Ko) for more information.

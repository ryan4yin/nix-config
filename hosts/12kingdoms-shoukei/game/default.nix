# x86/x86_64 applications and games on this Apple Silicon host.
#
# FEX cannot run on the 16K pages this machine boots with, so
# nix-x86-on-aarch64 runs FEX inside a 4K-page muvm microVM and owns the
# x86_64/i686 ELF handlers. Pinned to our fork; see WORKAROUNDS.md WA-021.
{ nix-x86-on-aarch64, ... }:
{
  imports = [ nix-x86-on-aarch64.nixosModules.default ];

  programs.x86-on-arm = {
    enable = true;
    steam.enable = true;
    wine.enable = true;
    # 16 GiB machine: cap what the guest may demand instead of muvm's 80% default.
    memoryMiB = 6144;
  };
}

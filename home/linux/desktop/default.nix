{ pkgs, ... }:
{
  imports = [
    ./creative.nix
    ./media.nix
  ];

  home.packages = with pkgs; [
    # networking
    wireshark

    # e-book viewer(.epub/.mobi/...)
    # do not support .pdf
    foliate

    # instant messaging
    telegram-desktop
    discord
    qq      # https://github.com/NixOS/nixpkgs/tree/master/pkgs/applications/networking/instant-messengers/qq
    
    # remote desktop(rdp connect)
    remmina
    freerdp  # required by remmina

    # the vscode insiders is designed to run alongside the main build, 
    # with a separate code-insiders command and a different config path
    ((pkgs.vscode.override { isInsiders = true; }).overrideAttrs (oldAttrs: rec {
      src = (builtins.fetchTarball {
        url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
        # you need to update this sha256 every time you update vscode insiders
        # the latest sha256 is printed in the error message of `sudo nixos-rebuild switch`
        sha256 = "sha256:1f996x5i85zf0hpd7jx18zdqdp9nhxhf6zn83ai0njphz1dj354p";
      });
      version = "latest";
    }))
  ];
}
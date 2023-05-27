{ pkgs, ... }:
{
  imports = [
    ./creative.nix
    ./media.nix
  ];

  home.packages = with pkgs; [
    # networking
    wireshark

    # instant messaging
    telegram-desktop
    discord
    qq      # https://github.com/NixOS/nixpkgs/tree/master/pkgs/applications/networking/instant-messengers/qq
    
    # remote desktop(rdp connect)
    remmina
    freerdp  # required by remmina
  ];
}
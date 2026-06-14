{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pcsc-tools
  ];
}

{pkgs, ...}: {
  home.packages = with pkgs; [
    clash-meta
  ];
  home.file.".proxychains/proxychains.conf".source = ./proxychains.conf;
}

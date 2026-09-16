{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    nixpaks.firefox
  ];

  # source code: https://github.com/nix-community/home-manager/blob/master/modules/programs/chromium.nix

  # open-source upstream Chromium, the base for all the browsers below
  programs.chromium.enable = true;
  # the world's most widely used browser, with deep Google account and services integration
  programs.google-chrome.enable = true;
  # Brave's privacy-first build (Shields ad/tracker blocking), minus the crypto/AI extras
  programs.brave-origin.enable = true;
  # Microsoft's browser, with built-in phishing/malware protection, x86_64 build only
  programs.microsoft-edge.enable = pkgs.stdenv.hostPlatform.isx86_64;
}

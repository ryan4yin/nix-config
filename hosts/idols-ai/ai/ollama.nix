{
  pkgs,
  nixpkgs-ollama,
  ...
}:
let
  pkgs-ollama = import nixpkgs-ollama {
    inherit (pkgs) system;
    # To use cuda, we need to allow the installation of non-free software
    config.allowUnfree = true;
  };
in
{
  services.ollama = rec {
    enable = true;
    package = pkgs-ollama.ollama;
    acceleration = "cuda";
    host = "0.0.0.0";
    port = 11434;
    home = "/var/lib/ollama";
    models = "${home}/models";
  };
}

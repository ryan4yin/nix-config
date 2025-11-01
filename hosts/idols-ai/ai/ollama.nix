{
  pkgs-patched,
  ...
}:
let

in
{
  services.ollama = rec {
    enable = true;
    package = pkgs-patched.ollama;
    acceleration = "cuda";
    host = "0.0.0.0";
    port = 11434;
    home = "/var/lib/ollama";
    models = "${home}/models";
  };
}

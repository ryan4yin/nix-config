{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nodejs_24
    pnpm

    #-- python
    conda
    (python313.withPackages (
      ps: with ps; [
        pipx # Install and Run Python Applications in Isolated Environments
        uv # python project package manager

        pandas
        requests
        pyquery
        pyyaml
        numpy

        huggingface-hub # huggingface-cli
      ]
    ))

    rustc
    cargo # rust package manager
    go
  ];
}

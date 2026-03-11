{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nodejs_24
    pnpm

    #-- python
    conda
    uv # python project package manager
    pipx # Install and Run Python Applications in Isolated Environments
    (python313.withPackages (
      ps: with ps; [
        pandas
        requests
        pyquery
        pyyaml
        numpy

        # model downloaders
        huggingface-hub
        modelscope
      ]
    ))

    rustc
    cargo # rust package manager
    go
  ];
}

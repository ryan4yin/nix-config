{ inputs, ... }: _final: prev: {
  computer-use-linux =
    inputs.nur-ryan4yin.packages.${prev.stdenv.hostPlatform.system}.computer-use-linux;
}

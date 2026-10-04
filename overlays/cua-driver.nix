{ inputs, ... }: _final: prev: {
  cua-driver = inputs.nur-ryan4yin.packages.${prev.stdenv.hostPlatform.system}.cua-driver;
}

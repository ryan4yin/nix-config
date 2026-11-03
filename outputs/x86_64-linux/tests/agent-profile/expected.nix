{ ... }:
let
  common = {
    agentsFromHome = true;
    devToolsFromHome = true;
    nushellSecrets = false;
    nixLd = true;
    rootlessPodman = true;
    docker = false;
    linger = true;
    agentsInSystem = false;
  };
in
{
  aquamarine = common // {
    computerUse = false;
    nixosTest = false;
  };
  ruby = common // {
    computerUse = true;
    nixosTest = true;
  };
  kana = common // {
    computerUse = true;
    nixosTest = true;
  };
}

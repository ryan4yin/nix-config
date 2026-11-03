{ ... }:
let
  common = {
    agentsFromHome = true;
    qwenInstalled = true;
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
  };
  ruby = common // {
    computerUse = true;
  };
  kana = common // {
    computerUse = true;
  };
}

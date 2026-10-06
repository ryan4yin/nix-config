# Evaluate the dsh module on its own: reading `home.file` from a real host would
# force the catppuccin theme derivations, turning an eval test into a build.
let
  module = import ../../../../home/base/tui/agents/dsh/default.nix;
  evaluated = module {
    config = {
      home.homeDirectory = "/home/tester";
      lib.file.mkOutOfStoreSymlink = path: path;
    };
  };
in
{
  keys = builtins.attrNames evaluated.home.file;
  source = toString evaluated.home.file.".dsh/cordis.patch.yml".source;
}

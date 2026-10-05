# The dsh module is evaluated on its own here. Reading `home.file` out of a real
# host would force the catppuccin theme derivations, which turns an eval test
# into a build, and the profile link is system-independent anyway. The stub
# supplies the only two config values the module reads.
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
  source = toString evaluated.home.file.".dsh/profiles/web".source;
}

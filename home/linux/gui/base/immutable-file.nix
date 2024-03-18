{
  config,
  lib,
  pkgs,
  ...
}:
##############################################################################################
#
#  Provide a option `home.immutable-file`, it works like `home.file` but make the generated file immutable.
#
#  Copy from https://github.com/iosmanthus/nixos-config/blob/349917b/modules/immutable-file.nix
#
#  this module use the `chattr +i` to make the file immutable, `i` indicates `immutable`,
#  it's a i-node flags only works on Linux.
#
#  TODO not used yet, need to test it.
#
##############################################################################################
with lib; let
  cfg = config.home.immutable-file;
  immutableFileOpts = _: {
    options = {
      src = mkOption {
        type = types.path;
      };
      dst = mkOption {
        type = types.path;
      };
    };
  };
  mkImmutableFile = pkgs.writeScript "make_immutable_file" ''
    # $1: dst
    # $2: src
    if [ ! -d "$(dirname $1)" ]; then
      mkdir -p $1
    fi

    if [ -f $1 ]; then
        sudo chattr -i $1
    fi

    sudo cp $2 $1
    sudo chattr +i $1
  '';
in {
  options.home.immutable-file = mkOption {
    type = with types; attrsOf (submodule immutableFileOpts);
    default = {};
  };

  config = mkIf (cfg != {}) {
    home.activation =
      mapAttrs'
      (name: {
        src,
        dst,
      }:
        nameValuePair
        "make-immutable-${name}"
        (lib.hm.dag.entryAfter ["writeBoundary"] ''
          ${mkImmutableFile} ${dst} ${src}
        ''))
      cfg;
  };
}

{
  lib,
  myvars,
  outputs,
}:
import ../../../x86_64-linux/tests/security-exporters/expr.nix { inherit lib myvars outputs; }

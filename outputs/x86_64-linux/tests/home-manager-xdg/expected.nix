{ myvars, lib }:
let
  username = myvars.username;
in
lib.genAttrs
  [
    "ai-niri"
    "aquamarine"
    "ruby"
  ]
  (_: {
    enable = true;
    stateHome = "/home/${username}/.local/state";
  })

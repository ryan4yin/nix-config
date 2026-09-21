{
  myvars,
  lib,
}:
let
  hosts = [
    "ruby"
    "kana"
  ];
in
lib.genAttrs hosts (name: {
  computerUse = true;
  atspi = true;
  clashVerge = true;
  timeZone = "America/Los_Angeles";
  xvfbRestart = "always";
  i3Restart = "always";
  vnc = true;
  cuaDriver = name == "ruby";
  brave = true;
  chromium = true;
})

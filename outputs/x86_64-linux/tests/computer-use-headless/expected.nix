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
  mihomo = false;
  timeZone = "America/Los_Angeles";
  xvfbRestart = "always";
  i3Restart = "always";
  vnc = true;
  clipboardSync = true;
  cuaDriver = true;
  cuaTelemetryDisabled = true;
  brave = true;
  chromium = true;
})

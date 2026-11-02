{ pkgs, ... }:
let
  offProfile = ./off.json;
in
{
  # The MSI ARGB controller loses its state on power loss and reverts to the
  # firmware default. Load an OpenRGB profile after detection so the service
  # restores the desired Direct/black state on every boot.
  services.hardware.openrgb = {
    enable = true;
    startupProfile = "off";
  };

  # Keep the profile checked in, and install it before the server starts. An
  # empty controller list with base_color = 0 makes OpenRGB apply black to every
  # detected controller.
  systemd.services.openrgb.preStart = ''
    ${pkgs.coreutils}/bin/install -Dm0644 ${offProfile} /var/lib/OpenRGB/profiles/off.json
  '';

  # The controller drops its LED state on resume without re-enumerating, so no
  # udev event fires; reapply the profile through the running server instead.
  systemd.services.openrgb-resume = {
    description = "Reapply the OpenRGB profile after resume";
    after = [ "suspend.target" ];
    wantedBy = [ "suspend.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.openrgb}/bin/openrgb --profile ${offProfile}";
    };
  };
}

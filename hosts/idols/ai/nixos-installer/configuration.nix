{...}: {
  networking.hostName = "ai";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.defaultGateway = "192.168.5.201";

  system.stateVersion = "23.11";
}

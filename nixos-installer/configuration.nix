{pkgs, ...}: {
  # ssh-agent is used to pull my private secrets repo from github when depoloying my nixos config.
  programs.ssh.startAgent = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git
    gnumake
    wget
    curl
    nix-output-monitor
  ];
  networking = {
    # configures the network interface(include wireless) via `nmcli` & `nmtui`
    networkmanager.enable = true;
    defaultGateway = "192.168.5.201";
  };
  system.stateVersion = "23.11";
}

{
  programs.wireshark = {
    enable = true;
    # Whether to allow users in the 'wireshark' group to capture network traffic(via a setcap wrapper).
    dumpcap.enable = true;
    # Whether to allow users in the 'wireshark' group to capture USB traffic (via udev rules).
    usbmon.enable = false;
  };
}

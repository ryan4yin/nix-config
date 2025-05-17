{
  lib,
  pkgs,
  ...
}: let
  my_terminal_desktop = [
    "foot.desktop"
    "Alacritty.desktop"
    "kitty.desktop"
    "com.mitchellh.ghostty.desktop"
  ];
in {
  environment.systemPackages = with pkgs; [
    # NOTE: We have these in home config
    # foot
    # Alacritty
    # kitty
    # ghostty
  ];
  xdg.terminal-exec = {
    enable = true;
    package = pkgs.xdg-terminal-exec-mkhl;
    settings = {
      GNOME =
        [
          "com.raggesilver.BlackBox.desktop"
          "org.gnome.Terminal.desktop"
        ]
        ++ my_terminal_desktop;
      niri = my_terminal_desktop;
      default = my_terminal_desktop;
    };
  };
}

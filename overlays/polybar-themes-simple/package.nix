{
  pkgs,
  polybar-themes,
  ...
}:

# use the themes provided by:
# https://github.com/adi1090x/polybar-themes
pkgs.nuenv.mkDerivation {
  name = "polybar-themes-simple";
  src = polybar-themes;
  debug = true;
  packages = [pkgs.coreutils];
  build = ''
    let out_fonts = $"($env.out)/fonts"
    mkdir $out_fonts
    cp -rf fonts/* $out_fonts

    let out_themes = $"($env.out)/themes"
    mkdir $out_themes
    cp -rf simple/* $out_themes

    # adjust the font size
    ls "simple/**/config.ini" | each { |it|
      let tmp_it = $"tmp/($it.name)"
      # prepare the output directory
      $tmp_it | path dirname | mkdir $in
      echo $"cusomizing ($it.name) and saving to ($tmp_it)"

      open $it.name
      # remova all font settings
      | str replace --all --multiline -r "font-[0-4].*=.+|height.*=.+" ""
      # add hidpi font settings
      | append "
    height = 64
    ; Text Fonts
    font-0 = Iosevka Nerd Font:style=Medium:size=15;4

    ; Icons Fonts
    font-1 = feather:style=Medium:size=24;3

    ; Powerline Glyphs
    font-2 = Iosevka Nerd Font:style=Medium:size=32;3

    ; Larger font size for bar fill icons
    font-3 = Iosevka Nerd Font:style=Medium:size=24;4

    ; Smaller font size for shorter spaces
    font-4 = Iosevka Nerd Font:style=Medium:size=12;4
      "
      | save -f $tmp_it
    }

    echo "all the themes:"
    let log = ls tmp/**/*
    echo $log
    echo "copying the tmp themes to ($out_themes)"
    cp -rf tmp/simple/* $out_themes
  '';
}

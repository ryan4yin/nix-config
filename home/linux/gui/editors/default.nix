{ pkgs-master, ... }:
{
  home.packages = with pkgs-master; [
    zed-editor
    (code-cursor.overrideAttrs (oldAttrs: rec {
      pname = "cursor";
      version = "2.0.77";
      src = appimageTools.extract {
        inherit pname version;
        src =
          let
            sources = {
              x86_64-linux = fetchurl {
                # curl -s https://api2.cursor.sh/updates/api/download/stable/linux-x64/cursor | jq
                url = "https://downloads.cursor.com/production/ba90f2f88e4911312761abab9492c42442117cfe/linux/x64/Cursor-2.0.77-x86_64.AppImage";
                hash = "";
              };
              aarch64-linux = fetchurl {
                # curl -s https://api2.cursor.sh/updates/api/download/stable/linux-arm64/cursor | jq
                url = "https://downloads.cursor.com/production/ba90f2f88e4911312761abab9492c42442117cfe/linux/arm64/Cursor-2.0.77-aarch64.AppImage";
                hash = "";
              };
            };
          in
          sources.${pkgs.system};
      };
      sourceRoot = "${pname}-${version}-extracted/usr/share/cursor";
    }))
  ];
}

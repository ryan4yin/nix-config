{ pkgs-master, ... }:
{
  home.packages = with pkgs-master; [
    zed-editor
    (code-cursor.overrideAttrs (oldAttrs: rec {
      pname = "cursor";
      version = "2.0.43";
      src = appimageTools.extract {
        inherit pname version;
        src =
          let
            sources = {
              x86_64-linux = fetchurl {
                # 2.0.43
                # curl -s https://api2.cursor.sh/updates/api/download/stable/linux-x64/cursor | jq
                url = "https://downloads.cursor.com/production/8e4da76ad196925accaa169efcae28c45454cce3/linux/x64/Cursor-2.0.43-x86_64.AppImage";
                hash = "sha256-ok+7uBlI9d3a5R5FvMaWlbPM6tX2eCse7jZ7bmlPExY=";
              };
              aarch64-linux = fetchurl {
                # 1.7.52
                # curl -s https://api2.cursor.sh/updates/api/download/stable/linux-arm64/cursor | jq
                url = "https://downloads.cursor.com/production/9675251a06b1314d50ff34b0cbe5109b78f848cd/linux/arm64/Cursor-1.7.52-aarch64.AppImage";
                hash = "sha256-96zL0pmcrEyDEy8oW2qWk6RM8XGE4Gd2Aa3Hhq0qvk0=";
              };
            };
          in
          sources.${pkgs.system};
      };
      sourceRoot = "${pname}-${version}-extracted/usr/share/cursor";
    }))
  ];
}

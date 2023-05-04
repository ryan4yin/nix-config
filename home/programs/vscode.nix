{ 
  config,
  pkgs,
  home-manager,
  nix-vscode-extensions,
  ... 
}: 

{

  # if use vscode in wayland, uncomment this line
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";
  programs.vscode = {
    enable = true;
    userSettings = {
      "editor.renderWhitespace" = "all";
      "files.autoSave" = "onFocusChange";
      "editor.rulers" = [ 80 120 ];
      "telemetry.enableTelemetry" = false;
      "telemetry.enableCrashReporter" = false;
      "editor.tabSize" = 2;
      "files.exclude" = { "**/node_modules/**" = true; };
      "editor.formatOnSave" = false;
      "breadcrumbs.enabled" = true;
      "editor.useTabStops" = false;
      "editor.fontFamily" = "JetBrainsMono Nerd Font";
      "editor.fontSize" = 16;
      "editor.fontLigatures" = true;
      "editor.lineHeight" = 20;
      "workbench.fontAliasing" = "antialiased";
      "files.trimTrailingWhitespace" = true;
      "editor.minimap.enabled" = false;
      "workbench.editor.enablePreview" = false;
      "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font";
    };

    package = 
      let 
        config.packageOverrides = pkgs: {
          vscode = pkgs.vscode-with-extensions.override {
            # pkgs.vscode-extensions 里包含的 vscode 太少了
            # 必须使用社区的 <https://github.com/nix-community/nix-vscode-extensions> 才能安装更多插件
            vscodeExtensions = with nix-vscode-extensions.extensions; [
              aaron-bond.better-comments
              anweber.vscode-httpyac
              arrterian.nix-env-selector
              bierner.markdown-mermaid
              christian-kohler.path-intellisense
              cschlosser.doxdocgen
              DanishSarwar.reverse-search
              eamodio.gitlens
              esbenp.prettier-vscode
              espressif.esp-idf-extension
              fabiospampinato.vscode-diff
              GitHub.copilot
              golang.go
              hashicorp.terraform
              janisdd.vscode-edit-csv
              jebbs.plantuml
              jeff-hykin.better-cpp-syntax
              jnoortheen.nix-ide
              JuanBlanco.solidity
              k--kato.intellij-idea-keybindings
              llvm-vs-code-extensions.vscode-clangd
              mcu-debug.debug-tracker-vscode
              mcu-debug.memory-view
              mcu-debug.rtos-views
              mikestead.dotenv
              mkhl.direnv
              ms-azuretools.vscode-docker
              ms-dotnettools.vscode-dotnet-runtime
              ms-kubernetes-tools.vscode-kubernetes-tools
              ms-python.isort
              ms-python.python
              ms-python.vscode-pylance
              ms-toolsai.jupyter
              ms-toolsai.jupyter-keymap
              ms-toolsai.jupyter-renderers
              ms-toolsai.vscode-jupyter-cell-tags
              ms-toolsai.vscode-jupyter-slideshow
              ms-vscode-remote.remote-containers
              ms-vscode-remote.remote-ssh
              ms-vscode-remote.remote-ssh-edit
              ms-vscode-remote.vscode-remote-extensionpack
              ms-vscode.cmake-tools
              ms-vscode.cpptools
              ms-vscode.cpptools-extension-pack
              ms-vscode.cpptools-themes
              ms-vscode.remote-explorer
              ms-vscode.remote-server
              pinage404.nix-extension-pack
              platformio.platformio-ide
              pomdtr.excalidraw-editor
              redhat.java
              redhat.vscode-commons
              redhat.vscode-xml
              redhat.vscode-yaml
              rust-lang.rust-analyzer
              shd101wyy.markdown-preview-enhanced
              sumneko.lua
              tamasfe.even-better-toml
              timonwong.shellcheck
              tintinweb.graphviz-interactive-preview
              tintinweb.solidity-visual-auditor
              tintinweb.vscode-inline-bookmarks
              tintinweb.vscode-solidity-flattener
              tintinweb.vscode-solidity-language
              twxs.cmake
              vadimcn.vscode-lldb
              VisualStudioExptTeam.intellicode-api-usage-examples
              VisualStudioExptTeam.vscodeintellicode
              vscjava.vscode-java-debug
              vscjava.vscode-java-pack
              vscjava.vscode-java-test
              vscjava.vscode-maven
              vscode-icons-team.vscode-icons
              WakaTime.vscode-wakatime
              yzhang.markdown-all-in-one
              zxh404.vscode-proto3
            ];
          };
        };
      in
        pkgs.vscode;
  };
}
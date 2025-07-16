{config, ...}: {
  # make `npm install -g <pkg>` happey
  #
  # mainly used to install npm packages that updates frequently
  # such as gemini-cli, claude-code, etc.
  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm
  '';
}

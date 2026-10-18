# Nushell as the only dsh shell: every ctx.shell execution runs as
# `nu --no-config-file -c`, a command handed to another shell is refused, and the
# model is taught Nushell. The bundle comes from the pinned `develop` branch of
# ryan4yin's fork; flake.lock locks the reviewed commit and WORKAROUNDS.md WA-038
# records the pin.
# It is mounted here instead of installed into a profile so the shell choice stays
# declarative and a rebuild can roll it back with the rest of the configuration.
#
# This is a home-layer patch rather than a profile patch: the shell choice is part
# of the machine configuration, not personal profile state. Patch layers apply
# bundles -> profile -> home -> --patch, so a `--patch` overlay can roll the shell
# back without a rebuild.
{
  pkgs,
  inputs,
  nur-ryan4yin,
  ...
}:
let
  plugin = inputs.dsh-nushell-only;
  nu = pkgs.nushell;
  dsh = nur-ryan4yin.packages.${pkgs.stdenv.hostPlatform.system}.dsh;
  # The plugin imports @deepseek-ai peer packages as bare specifiers; dsh's own
  # module fallback only resolves them for profile installs, so a store-path mount
  # needs the installed dsh peer scope beside the copied source.
  peers = "${dsh}/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai";
  bundle = pkgs.runCommandLocal "dsh-nushell-only-bundle" { } ''
    mkdir -p $out/node_modules
    cp -r ${plugin}/lib $out/lib
    cp ${plugin}/package.json $out/package.json
    ln -s ${peers} $out/node_modules/@deepseek-ai
  '';
in
{
  home.file.".dsh/cordis.patch.yml".text = ''
    # Managed by home/base/tui/agents/dsh-nushell-only.nix.
    - id: bash-sandbox
      disabled: true
    - id: pwsh-sandbox
      disabled: true
    - insert:
        - id: nushell-executor
          name: ${bundle}/lib/executor.js
          config:
            nuPath: ${nu}/bin/nu
            timeoutMs: 60000
            maxTimeoutMs: 600000
            maxOutputBytes: 64000
            graceMs: 3000
            enforceNushellOnly: true
            requireNu: true
            verifyNu: true
        - id: nushell-teaching
          name: ${bundle}/lib/teaching.js
          config:
            guide: full
            rewriteToolDescriptions: true
            rules: true
  '';
}

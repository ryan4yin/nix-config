{
  description = "Python venv development template";

  inputs = {
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    ...
  }:
    utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      devShells.default = pkgs.mkShell {
        name = "pulumi-venv";
        venvDir = "./venv";
        buildInputs = with pkgs; [
          # A Python interpreter including the 'venv' module is required to bootstrap
          # the environment.
          python3Packages.python
          # This executes some shell code to initialize a venv in $venvDir before
          # dropping into the shell
          python3Packages.venvShellHook

          # pulumi related packages
          pulumi
          pulumictl
          tf2pulumi
          crd2pulumi
          pulumiPackages.pulumi-random
          pulumiPackages.pulumi-command
          pulumiPackages.pulumi-aws-native
          pulumiPackages.pulumi-language-go
          pulumiPackages.pulumi-language-python
          pulumiPackages.pulumi-language-nodejs
        ];

        # Run this command, only after creating the virtual environment
        postVenvCreation = ''
          unset SOURCE_DATE_EPOCH
          pip install -r requirements.txt
        '';

        # Now we can execute any commands within the virtual environment.
        # This is optional and can be left out to run pip manually.
        postShellHook = ''
          # allow pip to install wheels
          unset SOURCE_DATE_EPOCH

          # fix `libstdc++.so.6 => not found`
          LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib"
        '';
      };
    });
}

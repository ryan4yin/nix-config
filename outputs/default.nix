{
  self,
  nixpkgs,
  pre-commit-hooks,
  ...
}@inputs:
let
  inherit (inputs.nixpkgs) lib;
  mylib = import ../lib { inherit lib; };
  myvars = import ../vars { inherit lib; };

  # Add my custom lib, vars, nixpkgs instance, and all the inputs to specialArgs,
  # so that I can use them in all my nixos/home-manager/darwin modules.
  genSpecialArgs =
    system:
    let
      pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    inputs
    // {
      # The spread above exposes each flake input as a top-level argument.
      # Also expose the whole set as `inputs`, which the package overlays
      # (`overlays/*.nix`) receive via `import ../overlays args`.
      inherit
        inputs
        mylib
        myvars
        pkgs-stable
        ;

      # use unstable branch for some packages to get the latest updates
      # pkgs-unstable = import inputs.nixpkgs-unstable {
      #   inherit system; # refer the `system` parameter form outer scope recursively
      #   # To use chrome, we need to allow the installation of non-free software
      #   config.allowUnfree = true;
      # };
      pkgs-2505 = import inputs.nixpkgs-2505 {
        inherit system;
        # To use chrome, we need to allow the installation of non-free software
        config.allowUnfree = true;
      };
      pkgs-patched = import inputs.nixpkgs-patched {
        inherit system;
        # to use chrome, we need to allow the installation of non-free software
        config.allowUnfree = true;
      };
      pkgs-master = import inputs.nixpkgs-master {
        inherit system;
        # to use chrome, we need to allow the installation of non-free software
        config.allowUnfree = true;
      };
      pkgs-blender = import inputs.nixpkgs-blender {
        inherit system;
        config = lib.optionalAttrs (system == "x86_64-linux") {
          allowUnfree = true;
          cudaSupport = true;
          # CUDA compute capability 8.9 targets the RTX 4090 (Ada) and avoids building kernels
          # for unrelated GPU architectures.
          cudaCapabilities = [ "8.9" ];
        };
      };

      pkgs-x64 = import nixpkgs {
        system = "x86_64-linux";

        # To use chrome, we need to allow the installation of non-free software
        config.allowUnfree = true;

        overlays = import ../overlays args;
      };
    };

  # This is the args for all the haumea modules in this folder.
  args = {
    inherit
      inputs
      lib
      mylib
      myvars
      genSpecialArgs
      ;
  };

  # modules for each supported system
  nixosSystems = {
    x86_64-linux = import ./x86_64-linux (args // { system = "x86_64-linux"; });
    aarch64-linux = import ./aarch64-linux (args // { system = "aarch64-linux"; });
    # riscv64-linux = import ./riscv64-linux (args // {system = "riscv64-linux";});
  };
  darwinSystems = {
    aarch64-darwin = import ./aarch64-darwin (args // { system = "aarch64-darwin"; });
  };
  allSystems = nixosSystems // darwinSystems;
  allSystemNames = builtins.attrNames allSystems;
  nixosSystemValues = builtins.attrValues nixosSystems;
  darwinSystemValues = builtins.attrValues darwinSystems;
  allSystemValues = nixosSystemValues ++ darwinSystemValues;

  # Raw Colmena hive (nodes + meta), evaluated below into the exposed
  # `colmenaHive` output. The nix-community Colmena rewrite only reads
  # `colmenaHive`, so the raw hive is not an output of its own.
  rawColmenaHive = {
    meta =
      (
        let
          system = "x86_64-linux";
        in
        {
          # colmena's default nixpkgs & specialArgs
          nixpkgs = import nixpkgs { inherit system; };
          specialArgs = genSpecialArgs system;
        }
      )
      // {
        # per-node nixpkgs & specialArgs
        nodeNixpkgs = lib.attrsets.mergeAttrsList (
          map (it: it.colmenaMeta.nodeNixpkgs or { }) nixosSystemValues
        );
        nodeSpecialArgs = lib.attrsets.mergeAttrsList (
          map (it: it.colmenaMeta.nodeSpecialArgs or { }) nixosSystemValues
        );
      };
  }
  // lib.attrsets.mergeAttrsList (map (it: it.colmena or { }) nixosSystemValues);

  # Helper function to generate a set of attributes for each system
  forAllSystems = func: (nixpkgs.lib.genAttrs allSystemNames func);
in
{
  # Add attribute sets into outputs, for debugging
  debugAttrs = {
    inherit
      nixosSystems
      darwinSystems
      allSystems
      allSystemNames
      ;
  };

  # NixOS Hosts
  nixosConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.nixosConfigurations or { }) nixosSystemValues
  );

  # Colmena - remote deployment via SSH. The nix-community evaluator reads the
  # evaluated `colmenaHive` output built from the raw hive in the `let` block.
  colmenaHive = inputs.colmena.lib.makeHive rawColmenaHive;

  # macOS Hosts
  darwinConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.darwinConfigurations or { }) darwinSystemValues
  );

  # Packages
  packages = forAllSystems (system: allSystems.${system}.packages or { });

  # Eval Tests for all NixOS & darwin systems.
  evalTests = lib.lists.all (it: it.evalTests == { }) allSystemValues;

  checks = forAllSystems (
    system:
    {
      # eval-tests per system. `nix flake check` requires every check to be a
      # derivation, so wrap the boolean result in one instead of returning a bool.
      eval-tests =
        let
          pkgs = nixpkgs.legacyPackages.${system};
          results = allSystems.${system}.evalTests;
        in
        pkgs.runCommand "eval-tests" { } (
          if results == { } then
            "touch $out"
          else
            "echo 'eval tests failed: evalTests is not empty' >&2; exit 1"
        );

      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = mylib.relativeToRoot ".";
        hooks = {
          nixfmt = {
            enable = true;
            settings.width = 100;
          };
          # Source code spell checker
          typos = {
            enable = true;
            settings = {
              write = true; # Automatically fix typos
              configPath = ".typos.toml"; # relative to the flake root
              # git-hooks passes paths on the command line, which makes typos
              # ignore .typos.toml's extend-exclude, so repeat it here
              exclude = "rime-data/|home/base/gui/rime/flypy_user.txt";
            };
          };
          prettier = {
            enable = true;
            settings = {
              write = true; # Automatically format files
              configPath = ".prettierrc.yaml"; # relative to the flake root
            };
          };
          # deadnix.enable = true; # detect unused variable bindings in `*.nix`
          # statix.enable = true; # lints and suggestions for Nix code(auto suggestions)
        };
      };
    }
    // lib.optionalAttrs (system == "x86_64-linux") {
      # Test the shared firewall in disposable VMs, without real-host imports,
      # Home Manager or agenix identities. Linux eval tests remain cross-arch.
      security-exporters = import ../tests/security-exporters.nix {
        pkgs = nixpkgs.legacyPackages.${system};
        networking = myvars.networking;
      };
    }
  );

  # Development Shells
  devShells = forAllSystems (
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      default = pkgs.mkShell {
        packages = with pkgs; [
          # fix https://discourse.nixos.org/t/non-interactive-bash-errors-from-flake-nix-mkshell/33310
          bashInteractive
          # fix `cc` replaced by clang, which causes nvim-treesitter compilation error
          gcc
          # Nix-related
          nixfmt
          deadnix
          statix
          # spell checker
          typos
          # code formatter
          prettier
        ];
        name = "dots";
        inherit (self.checks.${system}.pre-commit-check) shellHook;
      };
    }
  );

  # Format the nix code in this flake
  formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
}

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
      pkgs-npu = import inputs.nixpkgs-npu {
        inherit system;
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
      # NUR packages for this system; modules use `myNurPkgs.dsh` instead of
      # repeating `nur-ryan4yin.packages.${pkgs.stdenv.hostPlatform.system}`.
      myNurPkgs = inputs.nur-ryan4yin.packages.${system};
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
  };
  darwinSystems = {
    aarch64-darwin = import ./aarch64-darwin (args // { system = "aarch64-darwin"; });
  };
  allSystems = nixosSystems // darwinSystems;
  allSystemNames = builtins.attrNames allSystems;
  nixosSystemValues = builtins.attrValues nixosSystems;
  darwinSystemValues = builtins.attrValues darwinSystems;
  allSystemValues = nixosSystemValues ++ darwinSystemValues;

  nixosConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.nixosConfigurations or { }) nixosSystemValues
  );

  # Per-node deployment settings from `mylib.colmenaSystem`, keyed by host name.
  colmenaDeployments = lib.attrsets.mergeAttrsList (map (it: it.colmena or { }) nixosSystemValues);

  # Raw Colmena hive (nodes + meta), evaluated below into the exposed
  # `colmenaHive` output. The nix-community Colmena rewrite only reads
  # `colmenaHive`, so the raw hive is not an output of its own.
  #
  # Each node is rebuilt from its `nixosConfigurations` entry: the same modules
  # (including the one `nixpkgs.lib.nixosSystem` appends), specialArgs and
  # system. Colmena applies `nodeNixpkgs`' overlays and config on top of the
  # node's own, so it gets a package set with none: not the node's `pkgs`, and
  # not `legacyPackages`, which carries the flake's own overlays.
  rawColmenaHive = {
    meta = {
      nixpkgs = import nixpkgs { system = "x86_64-linux"; };
      nodeNixpkgs = builtins.mapAttrs (
        name: _: import nixpkgs { inherit (nixosConfigurations.${name}.pkgs.stdenv.hostPlatform) system; }
      ) colmenaDeployments;
      nodeSpecialArgs = builtins.mapAttrs (
        name: _: nixosConfigurations.${name}._module.specialArgs
      ) colmenaDeployments;
    };
  }
  // builtins.mapAttrs (name: deployment: {
    imports = [
      deployment
      # Colmena evaluates with nixpkgs' plain lib, which lacks the version the
      # flake's lib reports; without this the toplevel differs (`26.11pre-git`).
      # Recorded as WA-042 in WORKAROUNDS.md.
      {
        system.nixos.versionSuffix = lib.trivial.versionSuffix;
        system.nixos.revision = lib.trivial.revisionWithDefault null;
      }
    ]
    ++ nixosConfigurations.${name}._module.args.modules;
  }) colmenaDeployments;

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
  inherit nixosConfigurations;

  # Colmena - remote deployment via SSH. The nix-community evaluator reads the
  # evaluated `colmenaHive` output built from the raw hive in the `let` block.
  colmenaHive = inputs.colmena.lib.makeHive rawColmenaHive;

  # macOS Hosts
  darwinConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.darwinConfigurations or { }) darwinSystemValues
  );

  # Packages
  packages = forAllSystems (system: allSystems.${system}.packages or { });

  # Eval Tests for all NixOS & darwin systems. Each system's `evalTests` lists its
  # failures, so an empty attrset means that system passed.
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
      # Load the audit rules in a VM: one rule that fails to load leaves
      # auditing off, which evaluation cannot catch.
      security-auditd = import ../tests/security-auditd.nix {
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (inputs) agenix;
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

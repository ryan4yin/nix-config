{
  lib,
  config,
  myvars,
  ...
}:
let
  cfg = config.modules.remote-builders;

  # Aquamarine - the headless AI inference server (hosts/idols-aquamarine/).
  # 24C/96G and boot.binfmt emulation for aarch64-linux and riscv64-linux, so it
  # serves all three platforms this flake targets. `aquamarine` is also its SSH
  # alias in /etc/ssh/ssh_config, and its host key is pinned in
  # /etc/ssh/ssh_known_hosts (vars/networking.nix).
  buildMachines = [
    {
      hostName = "aquamarine";
      systems = [
        "x86_64-linux" # native
        "aarch64-linux" # qemu-user via binfmt
        "riscv64-linux" # qemu-user via binfmt
      ];
      # `kvm` is omitted even though aquamarine virtualizes well: a foreign
      # derivation requiring it would otherwise be scheduled there and fail under
      # emulation instead of falling back to local execution.
      supportedFeatures = [
        "benchmark"
        "big-parallel"
      ];
      # root is the daemon's default trusted user on the builder; a normal user
      # would have to be made root-equivalent there to serve builds.
      sshUser = "root";
      # On the client's root daemon; secrets/nixos.nix writes it to this path.
      sshKey = "/etc/agenix/ssh-key-romantic";
      inherit (cfg) maxJobs speedFactor;
      protocol = "ssh-ng";
    }
  ];
in
{
  options.modules.remote-builders = {
    enable = lib.mkEnableOption "building through aquamarine instead of locally";

    # Nix ranks machines by (running jobs + 1) / speedFactor and picks the
    # lowest. Keeping this below 2 * speedFactor / 3 means the builder is
    # preferred for every job it has a slot for, while the slot count stays
    # under its core count and each job may use several cores anyway — part of
    # the machine is left for what it actually runs (llama-swap). Once the
    # slots are full, jobs go to the local machine.
    maxJobs = lib.mkOption {
      type = lib.types.ints.positive;
      default = 12;
      description = "Concurrent builds to run on the builder.";
    };

    speedFactor = lib.mkOption {
      type = lib.types.numbers.positive;
      default = 24;
      description = "Speed of the builder relative to this machine.";
    };
  };

  config = lib.mkIf cfg.enable {
    nix.distributedBuilds = true;
    nix.buildMachines = buildMachines;
  };
}

{
  myvars,
  mylib,
  daeuniverse,
  agenix,
  microvm,
  mysecrets,
  nuenv,
  ...
}: {
  imports = [
    # Include the microvm host module
    microvm.nixosModules.host
  ];

  microvm.vms = {
    suzi = {
      autostart = true;
      restartIfChanged = true;

      specialArgs = {inherit myvars mylib daeuniverse agenix mysecrets nuenv;};

      config.imports = [./suzi];
    };

    mitsuha = {
      autostart = true;
      restartIfChanged = true;

      specialArgs = {inherit myvars mylib nuenv;};

      config.imports = [./mitsuha];
    };
  };
}

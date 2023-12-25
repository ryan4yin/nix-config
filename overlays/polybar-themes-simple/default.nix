{polybar-themes, ...} : (_: super: {
  polybar-themes-simple = super.callPackage ./package.nix { inherit polybar-themes;};
})

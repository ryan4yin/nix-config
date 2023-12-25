# https://github.com/NixOS/nixpkgs/blob/master/lib/attrsets.nix
{lib, ...}: {
  # Generate an attribute set from a list.
  #
  #   lib.genAttrs [ "foo" "bar" ] (name: "x_" + name)
  #     => { foo = "x_foo"; bar = "x_bar"; }
  listToAttrs = lib.genAttrs;

  # Update only the values of the given attribute set.
  #
  #   mapAttrs
  #   (name: value: ("bar-" + value))
  #   { x = "a"; y = "b"; }
  #     => { foo = "bar-a"; foo = "bar-b"; }
  mapAttrs = lib.attrsets.mapAttrs;

  # Update both the names and values of the given attribute set.
  #
  #   mapAttrs'
  #   (name: value: nameValuePair ("foo_" + name) ("bar-" + value))
  #   { x = "a"; y = "b"; }
  #     => { foo_x = "bar-a"; foo_y = "bar-b"; }
  mapAttrs' = lib.attrsets.mapAttrs';

  # Merge a list of attribute sets into one. smilar to the operator `a // b`, but for a list of attribute sets.
  # NOTE: the later attribute set overrides the former one!
  #
  #   mergeAttrsList
  #   [ { x = "a"; y = "b"; } { x = "c"; z = "d"; } { g = "e"; } ]
  #   => { x = "c"; y = "b"; z = "d"; g = "e"; }
  mergeAttrsList = lib.attrsets.mergeAttrsList;

  # Generate a string from an attribute set.
  #
  #   attrsets.foldlAttrs
  #   (acc: name: value: acc + "\nexport ${name}=${value}")
  #   "# A shell script"
  #   { x = "a"; y = "b"; }
  #     =>
  #     ```
  #     # A shell script
  #     export x=a
  #     export y=b
  #    ````
  foldlAttrs = lib.attrsets.foldlAttrs;
}

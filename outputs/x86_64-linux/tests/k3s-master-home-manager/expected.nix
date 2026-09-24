{ lib, ... }:
lib.genAttrs [
  "k3s-test-1-master-1"
  "k3s-test-1-master-2"
  "k3s-test-1-master-3"
] (_: false)

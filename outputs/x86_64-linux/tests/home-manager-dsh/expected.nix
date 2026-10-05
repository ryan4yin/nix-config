{
  # The link targets the whole profile directory, not a file inside it: dsh's
  # atomic Settings write replaces a symlinked file on the first save, while a
  # directory link keeps the write inside the checkout.
  keys = [ ".dsh/profiles/web" ];
  source = "/home/tester/nix-config/home/base/tui/agents/dsh/web";
}

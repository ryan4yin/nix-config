{
  # Sign commits with the OpenPGP [S] subkey that both CanoKeys hold; the card's
  # touch cache covers a burst of commits. Desktop layer only, where the cards
  # are used; setup: docs/security-keys.md#commit-signing.
  programs.git = {
    signing.key = "BB8DFBAC2E9BE8F15649E3AA1F2440D500288E48"; # primary; gpg picks its [S] subkey
    # Not signByDefault: its tag.gpgSign turns every lightweight `git tag` into an annotated one.
    settings.commit.gpgSign = true;
    # The personal key carries no work address, so work commits stay unsigned.
    includes = [
      {
        condition = "gitdir:~/work/";
        contents.commit.gpgSign = false;
      }
    ];
  };
}

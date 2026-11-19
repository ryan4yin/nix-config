# Password Manager

- https://www.passwordstore.org/
- [awesome-password-store](https://github.com/tijn/awesome-password-store)
- <https://github.com/gopasspw/gopass>: reimplement in go, with more features.
- Clients
  - Android: <https://github.com/android-password-store/Android-Password-Store>
  - Browsers(Chrome/Firefox): <https://github.com/browserpass/browserpass-extension>

## Changing the GPG key

Change the key only when a CanoKey is lost or the key may be compromised; its subkeys never leave
the cards, so there is no scheduled rotation. `python3 scripts/gpg_canokey.py pass` switches the
store: it decrypts every entry with the old key before changing anything, runs `pass init`, then
checks that each entry opens with the new key alone and kept its content. The whole procedure, from
generating the key to retiring the old one, is in
[hardware security keys](../../../../docs/security-keys.md#pass-openpgp).

Once the old key is deleted, older revisions in the store's git history can no longer be decrypted.

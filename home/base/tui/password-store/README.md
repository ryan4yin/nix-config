# Password Manager

- https://www.passwordstore.org/
- [awesome-password-store](https://github.com/tijn/awesome-password-store)
- <https://github.com/gopasspw/gopass>: reimplement in go, with more features.
- Clients
  - Android: <https://github.com/android-password-store/Android-Password-Store>
  - Browsers(Chrome/Firefox): <https://github.com/browserpass/browserpass-extension>

## Changing the GPG key

Change the key every two or three years. `python3 scripts/gpg_canokey.py pass` switches the store:
it decrypts every entry with the old key before changing anything, runs `pass init`, then checks
that each entry opens with the new key alone and kept its content. The whole procedure, from
generating the key to retiring the old one, is in
[hardware security keys](../../../../docs/security-keys.md#pass-openpgp).

Once the old key is deleted, older revisions in the store's git history can no longer be decrypted.

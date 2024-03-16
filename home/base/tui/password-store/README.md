# Password Manager

- https://www.passwordstore.org/
- [awesome-password-store](https://github.com/tijn/awesome-password-store)
- <https://github.com/gopasspw/gopass>: reimplement in go, with more features.
- Clients
  - Android: <https://github.com/android-password-store/Android-Password-Store>
  - Brosers(Chrome/Firefox): <https://github.com/browserpass/browserpass-extension>

## How to change the gpg key of the pass password store?

To ensure security, we should change the GPG key every two or three years. Here is how to do this.

1. Create a new GPG key pair and backup it to a safe place.
2. Ensure you can access both the old and new GPG keys.
3. Update `./default.nix` to use the new GPG sub keys.
4. Check which Key `pass` currently uses:

   ```bash
   cd ~/.local/share/password-store/
   # check which key is used by pass
   cat .gpg-id
   # check which key is really used to encrypt the password
   gpg --list-packets path/to/any/password.gpg
   ```

5. Change the key used by `pass`:
   ```bash
   # change the key used by pass, see `man pass` for more details
   # you will be asked to enter the password of both the new and old keys
   # then pass will re-encrypt all the passwords with the new key
   pass init <new-key-id>
   ```
6. Check if the key is changed:
   ```bash
   # check which key is used by pass
   cat .gpg-id
   # check which key is really used to encrypt the password
   gpg --list-packets path/to/any/password.gpg
   ```
7. Delete the old GPG key pair:
   ```bash
   # delete the old key pair
   gpg --delete-secret-keys <old-key-id>
   gpg --delete-keys <old-key-id>
   ```

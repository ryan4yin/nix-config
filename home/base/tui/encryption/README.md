# Encryption

We have GnuPG & password-store installed by default, mainly for password management, authentication
& communication encryption.

We also have LUKS2 for disk encryption on Linux, and [rclone](https://rclone.org/crypt/) for
cross-platform data encryption & syncing.

[age](https://github.com/FiloSottile/age) may be more general for file encryption.

[Sops](https://github.com/getsops/sops/tree/main) can be used for file encryption too, if you prefer
using a Cloud provider for key management.

## Asymmetric Encryption

Both age, Sops & GnuPG provide asymmetric encryption, which is useful for encrypting files for a
specific user.

For modern use, age is recommended, as it use [AEAD encryption function -
ChaCha20-Poly1305][age Format v1], If you do not want to manage the keys by yourself, Sops is
recommended, as it use KMS for key management.

## Symmetric Encryption

Both age & GnuPG provide symmetric encryption, which is useful for encrypting files for a specific
user.

As described in [age Format v1][age Format v1], age use scrypt to encrypt and decrypt the file key
with a provided passphrase, which is more secure than GnuPG's symmetric encryption.

[age Format v1]: https://age-encryption.org/v1

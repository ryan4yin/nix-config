# GNU Privacy Guard(GnuPG)

> Official Website: https://www.gnupg.org/

The GNU Privacy Guard is a complete and free implementation of the OpenPGP standard as defined by
RFC4880 (also known as **PGP**). GnuPG allows to encrypt and sign your data and communication,
features a versatile key management system as well as access modules for all kind of public key
directories.

> In the following content, we will use GPG to refer to GnuPG tool, and PGP to refer to various
> concepts defined in the OpenPGP standard(e.g. PGP key, PGP key server).

Key functions of GnuPG:

1. Keypair(keyring) management
2. Sign and Verify your data
3. Encrypt and Decrypt your data

Main usage scenarios of GnuPG:

1. Sign or encrypt your email
   1. Verify or decrypt the email you received
2. Sign your git commit
3. Manage your ssh key
4. Encrypt your data and store it somewhere.

GnuPG/OpenPGP is complex, so while using it, I have been looking forward to finding an encryption
tool that is simple enough, functional enough, and widely adopted.

Currently I use both age & GnuPG:

1. Age for secrets encryption, it's simple and easy to use.
2. GnuPG for password-store, because pass, browserpass and Android Password Store all speak OpenPGP.

SSH no longer goes through GnuPG: each CanoKey holds a FIDO2 SSH key instead (no `[A]` subkey).

## My key

- An ed25519 `[C]` primary that never leaves its backup, an ed25519 `[S]` and a cv25519 `[E]` subkey
  on both CanoKeys. No secret key lives in any computer's keyring: `~/.gnupg` holds only the public
  key (from Home Manager) and stubs that point at the cards.
- The full key and its revocation certificate exist only in an age-encrypted backup on offline
  drives. The key also has its own GPG passphrase: it stays protected in a keyring whenever the
  backup is opened, and age's scrypt covers gpg's weak S2K (see section 0) against offline guessing.
- [`scripts/gpg_canokey.py`](../../../../scripts/gpg_canokey.py) generates the key, switches the
  password store to it and loads the cards, all in throwaway keyrings on tmpfs. The procedure is in
  [hardware security keys](../../../../docs/security-keys.md#pass-openpgp).

The sections below explain the GnuPG concepts behind that setup.

## Practical Cryptography for Developers

To use GnuPG seamlessly, some Practical Cryptography knowledge is required, here are some tutorials:

- English version: <https://github.com/nakov/Practical-Cryptography-for-Developers-Book>
- Chinese version: <https://thiscute.world/tags/cryptography/>

## Overview of GnuPG

> GnuPG's Official User Guides: <https://www.gnupg.org/documentation/guides.html>

> ArchWiki's GnuPG page: <https://wiki.archlinux.org/title/GnuPG>

### 0. How does GnuPG generate & protect your keypair?

Related Docs:

- [2021年，用更现代的方法使用PGP（上）][2021年，用更现代的方法使用PGP（上）]
- [Predictable, Passphrase-Derived PGP Keys][Predictable, Passphrase-Derived PGP Keys]
- [OpenPGP - The almost perfect key pair][OpenPGP - The almost perfect key pair]

GnuPG generate every secret key separately, and encrypt them with a symmetric key derived from your
passphrase. OpenPGP standard defines
[String-to-Key (S2K)](https://datatracker.ietf.org/doc/html/rfc4880#section-3.7) algorithm to derive
a symmetric key from your passphrase.

GnuPG's
[OpenPGP protocol specific options](https://gnupg.org/documentation/manuals/gnupg/OpenPGP-Options.html#OpenPGP-Options)
shows that:

```
--s2k-cipher-algo name

    Use name as the cipher algorithm for symmetric encryption with a passphrase if --personal-cipher-preferences and --cipher-algo are not given. The default is AES-128.
--s2k-digest-algo name

    Use name as the digest algorithm used to mangle the passphrases for symmetric encryption. The default is SHA-1.
--s2k-mode n

    Selects how passphrases for symmetric encryption are mangled. If n is 0 a plain passphrase (which is in general not recommended) will be used, a 1 adds a salt (which should not be used) to the passphrase and a 3 (the default) iterates the whole process a number of times (see --s2k-count).
--s2k-count n

    Specify how many times the passphrases mangling for symmetric encryption is repeated. This value may range between 1024 and 65011712 inclusive. The default is inquired from gpg-agent. Note that not all values in the 1024-65011712 range are legal and if an illegal value is selected, GnuPG will round up to the nearest legal value. This option is only meaningful if --s2k-mode is set to the default of 3.
```

The strongest options should be:

```
gpg --s2k-mode 3 --s2k-count 65011712 --s2k-digest-algo SHA512 --s2k-cipher-algo AES256 ...
```

To use the strongest options globally, you can specify these options in your `~/.gnupg/gpg.conf`.
I've added them to my Home Manager's `programs.gpg.settings` option.

### 1. PGP Key(Primary Key) generation

Key management is the core of OpenPGP standard / GnuPG.

GnuPG uses public-key cryptography so that users may communicate securely. In a public-key system,
each user has a pair of keys consisting of a private key and a public key. **A user's private key is
kept secret; it need NEVER be revealed. The public key may be given to anyone with whom the user
wants to communicate**. GnuPG uses a somewhat more sophisticated scheme in which a user has a
primary keypair and then zero or more additional subordinate keypairs. The primary and subordinate
keypairs are bundled to facilitate key management and the bundle can often be considered simply as
one keypair, or a keyring/keychain(which contains multiple sub key-pairs).

The script creates the key non-interactively, in a keyring on tmpfs:

```bash
gpg --quick-generate-key '<name> (pass) <address>' ed25519 cert never   # [C] primary
gpg --quick-add-key <primary-fingerprint> ed25519 sign never            # [S]
gpg --quick-add-key <primary-fingerprint> cv25519 encr never            # [E]
gpg --passwd <primary-fingerprint>                                      # its GPG passphrase
```

The primary key only certifies: it signs its own subkeys and revocations, so it can stay offline
while the subkeys do the daily work. The key does not expire; the revocation certificate in every
backup is the way to retire it.

### 2. Configuration Files

> https://www.gnupg.org/documentation/manuals/gnupg/GPG-Configuration.html

The generated keys are stored in `~/.gnupg` by default, the functions of each file are as follows:

```bash
› tree ~/.gnupg/
/Users/ryan/.gnupg/
|-- S.gpg-agent           # socket file
|-- S.gpg-agent.browser   # socket file
|-- S.gpg-agent.extra     # socket file
|-- S.gpg-agent.ssh       # socket file
|-- S.keyboxd             # socket file
|-- common.conf              # config file
|-- openpgp-revocs.d         # Revocation certificates
|   `-- F680C6D7215674ADEA421CC5E22EC419FF93EA98.rev
|-- private-keys-v1.d        # private keys with user info & protect by passphrase
|   |-- 2083133619AB24DC32DA68F9FE83C58D375284E3.key
|   `-- 9350704F120643C504491E92CA97255223778C8A.key
|-- public-keys.d            # public keys
|   |-- pubring.db
|   `-- pubring.db.lock
`-- trustdb.gpg              # a trust database

4 directories, 12 files
```

The functions of most files are quite clear at a glance, but the `trustdb.gpg` in them is a bit
difficult to understand. Here are the details: <https://www.gnupg.org/gph/en/manual/x334.html>

Home Manager will manage all the things in `~/.gnupg/` EXCEPT `~/.gnupg/openpgp-revocs.d/` and
`~/.gnupg/private-keys-v1.d/`, which is expected. With the subkeys on a CanoKey,
`private-keys-v1.d/` holds only stubs that name the card.

### 3. Usage Flags & Best Practice

In PGP, every keys has a **usage flag** to indicate its usage:

- `C` means this key can be used to **Certify** other keys, which means this key can be used to
  **create/delete/revoke/modify** other keys.
- `S` means this key can be used to **Sign** data.
- `E` means this key can be used to **Encrypt** data.
- `A` means this key can be used to **Authenticate** data with various non-GnuPG programs. The key
  can be used as e.g. an **SSH key**.

The **best practice**, and what this setup does:

1. One primary key with only the `C` flag, and one subkey per job: `S` and `E` here. Without a GPG
   SSH key there is no `A` subkey.
2. **The primary key is extremely important**: keep it only in offline backups, never in a daily
   keyring. Here it lives in age-encrypted backups on two drives kept in different places.
3. Keep the subkeys on hardware keys, one copy per key, so losing one CanoKey loses nothing. A
   subkey can be replaced with a new one signed by the primary.
4. Back up the revocation certificate together with the primary key, and never delete it: it is the
   last way out if the primary key is compromised.
5. A leaked revocation certificate can only revoke the key; your data stays safe, but generate a new
   key anyway.
6. A compromised primary key without a revocation certificate is the worst case, and even with one,
   OpenPGP has no good way to distribute it (see section 7).

### 4. Backup & Restore

`generate` writes `gpg-<fingerprint>.tar.age` to every backup drive: a tar holding `secret.asc` (the
primary key and both subkeys, still protected by the GPG passphrase) and `revocation.asc`, encrypted
with an age passphrase. It then restores the copy it wrote into a fresh keyring, checks that the key
has a passphrase, and imports the revocation certificate to prove that it revokes the key.

The age layer is there because GnuPG's own export protection is weak. Exporting a secret key and
inspecting it shows:

```bash
› gpg --armor --export-secret-keys <primary-fingerprint>! | nix run nixpkgs#pgpdump
...
        Sym alg - AES with 128-bit key(sym 7)
        Iterated and salted string-to-key(s2k 3):
                Hash alg - SHA1(hash 2)
                Count - 65011712(coded count 255)
...
```

As [Predictable, Passphrase-Derived PGP Keys][Predictable, Passphrase-Derived PGP Keys] says, gpg
ignores the `--s2k-*` options from `~/.gnupg/gpg.conf` here: the exported key is protected by `SHA1`
and `AES128`. age derives its key with `scrypt`, so the backup takes age's strength while the GPG
passphrase still protects the key once age has decrypted it.

Restore the secret key into a keyring on tmpfs, never into `~/.gnupg`:

```bash
age --decrypt <backup> | tar -xOf - secret.asc | gpg --import
```

`gpg_canokey.py card` does this to load a new CanoKey. Public keys come from Home Manager's
`programs.gpg.publicKeys`; do not import them by hand (`mutableKeys = false` makes the keyring
read-only anyway).

### 5. Signing & Verification

```bash
#  Make a cleartext signature.
gpg --clearsign <file>

# Make a detached signature, with text output.
gpg --armor --detach-sign <file>

# verify the file contains a valid signature.
gpg --verify <file>

# verify the file with a detached signature.
gpg --verify <file> <signature-file>
```

### 6. Encryption & Decryption

```bash
# Encrypt a file via recipient's public key, sign it via your private key for signing, and output cleartext.
# so that the recipient can decrypt it via his/her private key.
gpg --armor --sign --encrypt --recipient ryan4yin@linux.com <file>
# or use this short version
gpg -aser ryan4yin@linux.com <file>

# Decrypt a file via your private key, and verify the signature via the sender's public key.
gpg --decrypt <file>
# or
gpg -d <file>
```

If you just want to encrypt/decrypt a file quickly, you can use `age` with a passphrase, `gpg` can
also do this, but it's not recommended(as age(scrypt)'s more secure):

```bash
# Encrypt a file via symmetric encryption(AES256), and output cleartext.
gpg --armor --symmetric --cipher-algo AES256 <file>
# or
gpg -ac <file>

# Decrypt a file via symmetric encryption.
gpg --decrypt <file>
# or
gpg -d <file>
```

### 7. Public Key Exchange & Revocation

In the case of many users, it is very difficult to exchange public keys securely and reliably with
each other. In the Web world, There is a **Chain of Trust\*\*** to resolve this problem:

- A Certificate Authority(CA) is responsible to verify & sign all the certificate signing request.
- Web Server can safely transmit its Web Certificate to the client via TLS protocol.
- Client can verify the received Web Certificate via the CA's root certificate(which is built in
  Browser/OS).

But in OpenPGP:

- There is key servers to distribute(exchange) public keys, but it **do not verify the identity of
  the key owner**, and any uploaded data is **not allowed to be deleted**. Which make it **insecure
  and dangerous**.
  - Why key server is dangerous?
    - Many PGP novices follow various tutorials to upload various key with personal privacy (such as
      real names) to the public key server, and then find that they can't delete them, which is very
      embarrassing.
    - Anyone can upload a key to the key server, and claim that it is the key of a certain
      person(such as Linus), which is very insecure.
  - **key server** is not recommend to use.
- GnuPG will generate revocation certificate when generating
  keypair(`~/.gnupg/openpgp-revocs.d/<fingerprint>.rev`), anyone can import this certificate to
  revoke the keypair. But OpenPGP standard **DO NOT provide a way to distribute this certificate to
  others**.
  - Not to mention some key status query protocol like OCSP in Web PKI.
  - Users has to publish their revocation certificate to their blog, github profile or somewhere
    else, and others has to check it and run `gpg --import <revocation-certificate>` to revoke the
    keypair manually.

In summary, **there is no good way to distribute public keys and revoke them in OpenPGP**, which is
a big problem.

Currently, You have to distribute your public key or revocation certificate via your blog, github
profile, or somewhere else, and others has to check it and run `gpg --import` to import your public
key or revocation certificate manually.

Anyway, let's try to revoke a keypair:

```bash
› gpg --list-keys
gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
/home/ryan/.gnupg/pubring.kbx
-----------------------------
pub   ed25519/0x55859965C2742B4B 2024-01-09 [SC]
      Key fingerprint = A2CD 07BD 9631 44CB 2725  5A6B 5585 9965 C274 2B4B
uid                   [ultimate] test <test@test.t>
sub   cv25519/0x9E78E897B6490D6B 2024-01-09 [E]

# encrypt some file before revoke the keypair
› gpg -are test@test.t README.md > README.md.asc

# try to decrypt the file, it should work
› gpg -d README.md.asc
gpg: encrypted with cv25519 key, ID 0x9E78E897B6490D6B, created 2024-01-09
      "test <test@test.t>"
# ......

# take a look at the revocation certificate
› cat gpg-test-revoke.rev
This is a revocation certificate for the OpenPGP key:

pub   ed25519/0x55859965C2742B4B 2024-01-09 [S]
      Key fingerprint = A2CD 07BD 9631 44CB 2725  5A6B 5585 9965 C274 2B4B
uid                            test <test@test.t>

A revocation certificate is a kind of "kill switch" to publicly
declare that a key shall not anymore be used.  It is not possible
to retract such a revocation certificate once it has been published.

Use it to revoke this key in case of a compromise or loss of
the secret key.  However, if the secret key is still accessible,
it is better to generate a new revocation certificate and give
a reason for the revocation.  For details see the description of
of the gpg command "--generate-revocation" in the GnuPG manual.

To avoid an accidental use of this file, a colon has been inserted
before the 5 dashes below.  Remove this colon with a text editor
before importing and publishing this revocation certificate.

:-----BEGIN PGP PUBLIC KEY BLOCK-----
Comment: This is a revocation certificate

iHgEIBYKACAWIQSizQe9ljFEyyclWmtVhZllwnQrSwUCZZ1T9wIdAAAKCRBVhZll
wnQrS2LVAQCegRF1qPqY/OCS5QCz8G0ra0XgPYlQYo9pSOjHgfY39AD+Psin2/6t
STuJCp+gru6OtbTCu8Y2LugQeDh7UicM7Ak=
=Xfs6
-----END PGP PUBLIC KEY BLOCK-----
```

As the revocation certificate says, we need to remove the first colon(`:`) before the 5
dashes(`-----BEGIN PGP PUBLIC KEY BLOCK-----`), then import it:

```bash
› gpg --import gpg-test-revoke.rev
gpg: key 0x55859965C2742B4B: "test <test@test.t>" revocation certificate imported
gpg: Total number processed: 1
gpg:    new key revocations: 1
gpg: no ultimately trusted keys found

› gpg --list-secret-keys --keyid-format=long
/home/ryan/.gnupg/pubring.kbx
-----------------------------
sec   ed25519/55859965C2742B4B 2024-01-09 [SC] [revoked: 2024-01-09]
      Key fingerprint = A2CD 07BD 9631 44CB 2725  5A6B 5585 9965 C274 2B4B
uid                 [ revoked] test <test@test.t>


# try to decrypt the file, it still works, but will indicate that the key is revoked.
› gpg -d README.md.asc
gpg: encrypted with cv25519 key, ID 0x9E78E897B6490D6B, created 2024-01-09
      "test <test@test.t>"
gpg: Note: key has been revoked
gpg: reason for revocation: No reason specified
# ......

# try to encrypt some file via the revoked key, it will fail.
› gpg -are 9E78E897B6490D6B README.md
gpg: 9E78E897B6490D6B: skipped: Unusable public key
gpg: README.md: encryption failed: Unusable public key
```

But if you delete the `trustdb.gpg` and `pubring.kbx`, then import the revoked public key again, it
will be valid and usable again... which is very dangerous.

## References

- [2021年，用更现代的方法使用PGP（上）][2021年，用更现代的方法使用PGP（上）]
- [Predictable, Passphrase-Derived PGP Keys][Predictable, Passphrase-Derived PGP Keys]
- [OpenPGP - The almost perfect key pair][OpenPGP - The almost perfect key pair]

[2021年，用更现代的方法使用PGP（上）]:
  https://ulyc.github.io/2021/01/13/2021%E5%B9%B4-%E7%94%A8%E6%9B%B4%E7%8E%B0%E4%BB%A3%E7%9A%84%E6%96%B9%E6%B3%95%E4%BD%BF%E7%94%A8PGP-%E4%B8%8A/
[Predictable, Passphrase-Derived PGP Keys]: https://nullprogram.com/blog/2019/07/10/
[OpenPGP - The almost perfect key pair]:
  https://blog.eleven-labs.com/en/openpgp-almost-perfect-key-pair-part-1/

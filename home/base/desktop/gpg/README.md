# GNU Privacy Guard(GnuPG)

> Offical Website: https://www.gnupg.org/

The GNU Privacy Guard is a complete and free implementation of the OpenPGP standard as defined by RFC4880 (also known as **PGP**). GnuPG allows to encrypt and sign your data and communication, features a versatile key management system as well as access modules for all kind of public key directories. 

> In the following content, we will use GPG to refer to GnuPG tool, and PGP to refer to various concepts defined in the OepnPGP standard(e.g. PGP key, PGP key server).

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

GnuPG/OpenPGP is complex, so while using it, I have been looking forward to finding an encryption tool that is simple enough, functional enough, and widely adopted.

Currently I use both age & GnuPG:

1. Age for secrets encryption(ssh key & other secret files), it's simple and easy to use.
2. GnuPG for password-store and email encryption.

> At present, the safe and efficient use of GPG is probably combined with hardware keys such as yubikey. but I don't have one, so I won't talk about it here.

## Practical Cryptography for Developers

To use GnuGP without seamlessly, Some Practical Cryptography knowledge is required, here is dome tutorials:

- English version: <https://github.com/nakov/Practical-Cryptography-for-Developers-Book>
- Chinese version: <https://thiscute.world/tags/cryptography/>

## Overview of GnuPG

> GnuPG's Official User Guides: <https://www.gnupg.org/documentation/guides.html>

> ArchWiki's GnuPG page: <https://wiki.archlinux.org/title/GnuPG>

### 1. PGP Key(Primary Key) generation

Key management is the core of OpenPGP standard / GnuPG.

GnuPG uses public-key cryptography so that users may communicate securely. In a public-key system, each user has a pair of keys consisting of a private key and a public key. **A user's private key is kept secret; it need **never be revealed. The public key may be given to anyone with whom the user wants to communicate**. GnuPG uses a somewhat more sophisticated scheme in which a user has a primary keypair and then zero or more additional subordinate keypairs. The primary and subordinate keypairs are bundled to facilitate key management and the bundle can often be considered simply as one keypair, or a keyring/keychain(which contains multiple sub key-pairs).

Let's generate a keypair interactively:

> Now in 2024, GnuPG 2.4.1 defaults to ECC algorithm (9) and Curve 25519 for ECC, which is morden and safe, I would recommend to use these defaults directly.

```bash
gpg --full-gen-key
```

This command will ask you for some algorithm related settings(ECC & Curve 25519), your personal info, and a strong passphrase to protect your PGP key. e.g.

``` bash
› gpg --full-gen-key
gpg (GnuPG) 2.4.1; Copyright (C) 2023 g10 Code GmbH
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

gpg: directory '/Users/ryan/.gnupg' created
Please select what kind of key you want:
   (1) RSA and RSA
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
   (9) ECC (sign and encrypt) *default*
  (10) ECC (sign only)
  (14) Existing key from card
Your selection? 
Please select which elliptic curve you want:
   (1) Curve 25519 *default*
   (4) NIST P-384
   (6) Brainpool P-256
Your selection? 
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 
Key expires at 一  1/29 13:50:14 2024 CST
Is this correct? (y/N) 
Key is valid for? (0) 
Key expires at 一  1/ 4 13:50:31 2044 CST
Is this correct? (y/N) 

GnuPG needs to construct a user ID to identify your key.

Real name: 
Email address: 
Comment: 
You selected this USER-ID:
    "Ryan Yin (For Work) <ryan4yin@linux.com>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? 
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
gpg: /Users/ryan/.gnupg/trustdb.gpg: trustdb created
gpg: directory '/Users/ryan/.gnupg/openpgp-revocs.d' created
gpg: revocation certificate stored as '/Users/ryan/.gnupg/openpgp-revocs.d/C8D84EBC5F82494F432ACEF042E49B284C30A0DA.rev'
public and secret key created and signed.

pub   ed25519 2024-01-09 [SC] [expires: 2044-01-04]
      C8D84EBC5F82494F432ACEF042E49B284C30A0DA
uid                      Ryan Yin (For Work) <ryan4yin@linux.com>
sub   cv25519 2024-01-09 [E] [expires: 2044-01-04]
```

### 2. Configuration Files

> https://www.gnupg.org/documentation/manuals/gnupg/GPG-Configuration.html

The generated keys are stored in `~/.gnupg` by default, the functions of each file are as follows:

``` bash
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

The functions of most files are quite clear at a glance, but the `trustdb.gpg` in them is a bit difficult to understand. Here are the details: <https://www.gnupg.org/gph/en/manual/x334.html>

Home Manager will manage all the things in `~/.gnupg/` EXCEPT `~/.gnupg/openpgp-revocs.d/` and `~/.gnupg/private-keys-v1.d/`, which is expected.

### 3. Sub Key Generation & Best Practice

In PGP, every keys has a **usage flag** to indicate its usage:

- `C` means this key can be used to **Certify** other keys, which means this key can be used to **create/delete/revoke/modify** other keys.
- `S` means this key can be used to **Sign** data.
- `E` means this key can be used to **Encrypt** data. 
- `A` means this key can be used to **Authenticate** data with various non-GnuPG programs. The key can be used as e.g. an **SSH key**.

The **best practice** is:

1. Generate a primary key with strong cryptography arguments(such as ECC + Curve 25519).
2. Then generate 3 sub keys with `E`, `S` and `A` usage flag respectively.
3. **The Primary Key is extremely important**, Backup the primary key to somewhere absolutely safe(such as two encryptd USB drivers, keep them in different places), and then **delte it from your computer immediately**.
4. The sub key is also important, but you can generate a new one and replace it easily. You can backup it to somewhere else, and import it to another machine to use your keypair.
5. Backup your Primary key's revocation certificate to somewhere safe, it's the last way to rescure your safety if your primary key is compromised!
  1. It's a big problem if your revocation certificate is compromised, but not the bigest one. because it's only used to revoke your keypair, your data is still safe. But you should generate a new keypair and revoke the old one immediately.
  1. It will be a big problem if your primary key is compromised, and you don't have a revocation certificate to revoke it. But since OpenPGP do not have a good way to distribute revocation certificate, even you have a revocation certificate, it's still hard to distribute it to others...

To keep your keypair safe, you should backup your keypair according to the following steps.

Now let's add the sub keys to the keypair we generated above:

> `E` sub key is already generated by default, so we only need to generate `S` and `A` sub keys.

> GnuPG will ask you to input your passphrase to unlock your primary key.

``` bash
› gpg --expert --edit-key ryan4yin@linux.com
gpg (GnuPG) 2.4.1; Copyright (C) 2023 g10 Code GmbH
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Secret key is available.

sec  ed25519/42E49B284C30A0DA
     created: 2024-01-09  expires: 2044-01-04  usage: SC
     trust: ultimate      validity: ultimate
ssb  cv25519/6CB4A81FFB3C99B6
     created: 2024-01-09  expires: 2044-01-04  usage: E
[ultimate] (1). Ryan Yin (For Work) <ryan4yin@linux.com>

gpg> addkey
Please select what kind of key you want:
   (3) DSA (sign only)
   (4) RSA (sign only)
   (5) Elgamal (encrypt only)
   (6) RSA (encrypt only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
  (12) ECC (encrypt only)
  (13) Existing key
  (14) Existing key from card
Your selection? 10
Please select which elliptic curve you want:
   (1) Curve 25519 *default*
   (2) Curve 448
   (3) NIST P-256
   (4) NIST P-384
   (5) NIST P-521
   (6) Brainpool P-256
   (7) Brainpool P-384
   (8) Brainpool P-512
   (9) secp256k1
Your selection? 1
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 20y
Key expires at Mon Jan  4 17:47:24 2044 CST
Is this correct? (y/N) y
Really create? (y/N) y
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.

sec  ed25519/42E49B284C30A0DA
     created: 2024-01-09  expires: 2044-01-04  usage: SC
     trust: ultimate      validity: ultimate
ssb  cv25519/6CB4A81FFB3C99B6
     created: 2024-01-09  expires: 2044-01-04  usage: E
ssb  ed25519/A42813E03A10F504
     created: 2024-01-09  expires: 2044-01-04  usage: S
[ultimate] (1). Ryan Yin (For Work) <ryan4yin@linux.com>

gpg> addkey
Please select what kind of key you want:
   (3) DSA (sign only)
   (4) RSA (sign only)
   (5) Elgamal (encrypt only)
   (6) RSA (encrypt only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
  (12) ECC (encrypt only)
  (13) Existing key
  (14) Existing key from card
Your selection? 11

Possible actions for this ECC key: Sign Authenticate
Current allowed actions: Sign

   (S) Toggle the sign capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? S

Possible actions for this ECC key: Sign Authenticate
Current allowed actions:

   (S) Toggle the sign capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? A

Possible actions for this ECC key: Sign Authenticate
Current allowed actions: Authenticate

   (S) Toggle the sign capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? Q
Please select which elliptic curve you want:
   (1) Curve 25519 *default*
   (2) Curve 448
   (3) NIST P-256
   (4) NIST P-384
   (5) NIST P-521
   (6) Brainpool P-256
   (7) Brainpool P-384
   (8) Brainpool P-512
   (9) secp256k1
Your selection? 1
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 20y
Key expires at Mon Jan  4 17:48:27 2044 CST
Is this correct? (y/N) y
Really create? (y/N) y
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.

sec  ed25519/42E49B284C30A0DA
     created: 2024-01-09  expires: 2044-01-04  usage: SC
     trust: ultimate      validity: ultimate
ssb  cv25519/6CB4A81FFB3C99B6
     created: 2024-01-09  expires: 2044-01-04  usage: E
ssb  ed25519/A42813E03A10F504
     created: 2024-01-09  expires: 2044-01-04  usage: S
ssb  ed25519/5469C4FACC81B60F
     created: 2024-01-09  expires: 2044-01-04  usage: A
[ultimate] (1). Ryan Yin (For Work) <ryan4yin@linux.com>

gpg> save
```

```bash
› gpg --list-secret-keys --with-subkey-fingerprint
[keyboxd]
---------
sec   ed25519 2024-01-09 [SC] [expires: 2044-01-04]
      C8D84EBC5F82494F432ACEF042E49B284C30A0DA
uid           [ultimate] Ryan Yin (For Work) <ryan4yin@linux.com>
ssb   cv25519 2024-01-09 [E] [expires: 2044-01-04]
      1146D48B93C2177C92D186026CB4A81FFB3C99B6
ssb   ed25519 2024-01-09 [S] [expires: 2044-01-04]
      DF64002A822948B17783BBB1A42813E03A10F504
ssb   ed25519 2024-01-09 [A] [expires: 2044-01-04]
      65E2C6C1C3559362ABB7047C5469C4FACC81B60F
```
 
### 4. Backup & Restore

Export Public Keys(Both Primary Key & Sub Keys):

```bash
gpg --armor --export ryan4yin@linux.com > public-key.pub
```

Export Primary Key(The exported key is still encrypted by your passphrase):

> the `!` at the end of the key ID is to force GnuPG to export only the specified key, not the subkeys.

> GnuPG will ask you to input your passphrase to unlock your keypair,
> because GnuPG need to convert the secret key's format from its internal protection format to the one specified by the OpenPGP protocol.

```bash
gpg --armor --export-secret-keys ryan4yin@linux.com C8D84EBC5F82494F432ACEF042E49B284C30A0DA! > ryan4yin-primary-key.sec
```

Export Sub Keys one by one(The exported key is still encrypted by your passphrase):

```bash
gpg --armor --export-secret-subkeys
```

Your can import the exported Private Key via `gpg --import <keyfile>` to restore it.

As for Public Keys, please import your publicKeys via Home Manager's `programs.gpg.publicKeys` option, DO NOT import it manually(via `gpg --import <keyfile>`).

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
# so that the reciiptent can decrypt it via his/her private key.
gpg --armor --sign --encrypt --recipient ryan4yin@linux.com <file>
# or use this short version
gpg -aser ryan4yin@linux.com <file>

# Descrypt a file via your private key, and verify the signature via the sender's public key.
gpg --decrypt <file>
# or
gpg -d <file>
```

If you just want to encrypt/decrypt a file quickly, you can use `age`, or use `gpg` with symmetric encryption:

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

In the case of many users, it is very difficult to exchange public keys securely and reliably with each other.
In the Web world, There is a **Chain of Trust**** to resolve this problem:

- A Certificate Authority(CA) is responsible to verify & sign all the certificate signing request.
- Web Server can safely transmit its Web Certificate to the client via TLS protocol.
- Client can verify the recevied Web Certificate via the CA's root certificate(which is built in Browser/OS). 

But in OpenPGP:

- There is key servers to distribute(exchange) public keys, but it **do not verify the identity of the key owner**, and any uploaded data is **not allowed to be deleted**. Which make it **insecure and dangerous**.
  - Why key server is dangerous?
    - Many PGP novices follow various tutorials to upload various key with personal privacy (such as real names) to the public key server, and then find that they can't delete them, which is very embarrassing.
    - Anyone can upload a key to the key server, and claim that it is the key of a certain person(such as Linus), which is very insecure.
  - **key server** is not recommend to use.
- GnuPG will generate revocation certificate when generating keypair(`~/.gnupg/private-keys-v1.d/<Key-ID.rev>`), anyone can import this certificate to revoke the keypair. But OpenPGP standard **DO NOT provide a way to distribute this certificate to others**.
  - Not to mention some key status query protocol like OCSP in Web PKI.
  - Users has to pulish their revocation certificate to their blog, github profile or somewhere else, and others has to check it and run `gpg --import <revocation-certificate>` to revoke the keypair manually.

In summary, **there is no good way to distribute public keys and revoke them in OpenPGP**, which is a big problem.

Currently, You have to distribute your public key or revocation certificate via your blog, github profile, or somewhere else, and others has to check it and run `gpg --import` to import your public key or revocation certificate manually.

## References

- [2021年，用更现代的方法使用PGP（上）](https://ulyc.github.io/2021/01/13/2021%E5%B9%B4-%E7%94%A8%E6%9B%B4%E7%8E%B0%E4%BB%A3%E7%9A%84%E6%96%B9%E6%B3%95%E4%BD%BF%E7%94%A8PGP-%E4%B8%8A/)


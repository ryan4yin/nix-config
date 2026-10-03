# My Private PKI / CA

This is my private Private Key Infrastructure (PKI) / Certificate Authority (CA) for my personal
use. It is used to issue certificates for my own servers and services.

## Current Structure

- **ecc-ca.crt** - ECC CA certificate file
- **ecc-ca.srl** - CA serial number file for certificate tracking
- **ecc-csr.conf** - OpenSSL configuration file for certificate signing requests
- **ecc-server.crt** - Server certificate signed by the ECC CA
- **gen-certs.sh** - Shell script to generate certificates automatically

## Security Notes

Private keys (`.key`) and certificate signing requests (`.csr`) are ignored by git; the keys are
stored in a private secrets repository. The public certificates and configuration files are
committed to this repository for reference.

## Usage

Run `bash gen-certs.sh` to generate new certificates using the ECC CA configuration.

See [../secrets](../secrets/) for the corresponding private key management.

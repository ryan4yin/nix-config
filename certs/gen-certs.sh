# 1. Generate the private key for Root CA
openssl ecparam -genkey -name secp384r1 -out ecc-ca.key
# 2. Generate the certificate for Root CA with the validity period of 10 years
# using the private key and some basic information
# NOTE: we specify sha512 as the signature algorithm, which is the key point
openssl req -x509 -new -SHA512 -key ecc-ca.key -subj "/CN=Ryan4Yin's Root CA 1" -days 3650 -out ecc-ca.crt

# 3. Generate the private key for web server
openssl ecparam -genkey -name secp384r1 -out ecc-server.key
# 4. Generate the certificate signing request (CSR) for the server certificate
# using the private key and the configuration file ecc-csr.conf
openssl req -new -SHA512 -key ecc-server.key -out ecc-server.csr -config ecc-csr.conf
# 5. Sign the server certificate with the Root CA's certificate and private key
# NOTE: we specify sha512 as the signature algorithm, which is the key point
openssl x509 -req -SHA512 -in ecc-server.csr -CA ecc-ca.crt -CAkey ecc-ca.key \
  -CAcreateserial -out ecc-server.crt -days 3650 \
  -extensions v3_ext -extfile ecc-csr.conf

# 6. Display the information of the certificates
openssl x509 -noout -text -in ecc-ca.crt
openssl x509 -noout -text -in ecc-server.crt


#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

# Function to create a certificate
create_certificate() {
    openssl req -new -subj "$1" -out "$2.csr" -keyout "$2.key" -nodes
    openssl x509 -req -days 3650 -extensions v3_req -CA "$3.crt" -CAkey "$3.key" -CAcreateserial -in "$2.csr" -out "$2.crt"
    echo "Created certificate: $2"
}

# Function to create a PEM bundle
create_pem_bundle() {
    cat "$1.crt" "$2.crt" "$3.crt" > "$4.pem"
    echo "Created .pem bundle: $4.pem"
}

# Ensure working directory exists
mkdir -p webserver/certs
cd webserver/certs

# Create the Root Certificate
openssl req -new -x509 -days 28 -extensions v3_ca -subj "/C=DE/O=haw-hamburg/CN=SVS-Root-CA" -out SVS-Root-CA.crt -keyout SVS-Root-CA.key -nodes
echo "Created root cert: SVS-Root-CA.crt"

# Create the Sub-CA
openssl req -new -subj "/C=DE/O=haw-hamburg/OU=SVS/CN=Sub-CA-10" -out Sub-CA-10.csr -keyout Sub-CA-10.key -nodes
openssl x509 -req -days 28 -extensions v3_req -CA SVS-Root-CA.crt -CAkey SVS-Root-CA.key -CAcreateserial -in Sub-CA-10.csr -out Sub-CA-10.crt
echo "Created sub-CA: Sub-CA-10.crt"

# Create the Sub-CA for Users
openssl req -new -subj "/C=DE/O=haw-hamburg/OU=SVS/CN=Sub-CA-10-User" -out Sub-CA-10-User.csr -keyout Sub-CA-10-User.key -nodes
openssl x509 -req -days 28 -extensions v3_req -CA SVS-Root-CA.crt -CAkey SVS-Root-CA.key -CAcreateserial -in Sub-CA-10-User.csr -out Sub-CA-10-User.crt
echo "Created sub-CA for users: Sub-CA-10-User.crt"

# Create a certificate for the server
create_certificate "/C=DE/O=haw-hamburg/OU=SVS/CN=svs10.ful.informatik.haw-hamburg.de" "svs10.ful.informatik.haw-hamburg.de" "Sub-CA-10"

# Ensure user directory exists
mkdir -p users

# Create dummy user certificates
for i in {1..10}; do
    create_certificate "/C=DE/O=haw-hamburg/OU=SVS/CN=Dummy-$i" "dummy-10-$i" "Sub-CA-10-User"
    openssl pkcs12 -export -out users/dummy-10-$i.p12 -inkey dummy-10-$i.key -in dummy-10-$i.crt -certfile Sub-CA-10-User.crt -passout pass:password
    mv dummy-10-$i.* users/
done

# Create the PEM bundle
create_pem_bundle "SVS-Root-CA" "Sub-CA-10" "svs10.ful.informatik.haw-hamburg.de" "svs10"

# Create the chain certificates
cat SVS-Root-CA.crt Sub-CA-10.crt svs10.ful.informatik.haw-hamburg.de.crt > chain.crt
cat SVS-Root-CA.crt Sub-CA-10-User.crt > chain-user.crt

echo "Done"

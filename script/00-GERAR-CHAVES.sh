#!/bin/bash

mkdir -p backend/src/main/resources/Keys

openssl genrsa -out backend/src/main/resources/Keys/private_key.pem 2048

openssl rsa \
  -in backend/src/main/resources/Keys/private_key.pem \
  -pubout \
  -out backend/src/main/resources/Keys/public_key.pem

echo "Chaves RSA geradas com sucesso."
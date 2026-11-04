#!/usr/bin/env bash
# ============================================================
# PETCARE HUB - 00 - GERAR CHAVES RSA PARA O JWT
# Gera a chave privada no formato PKCS#8 (-----BEGIN PRIVATE KEY-----),
# que é o formato que o Spring Security exige.
# Rodar na raiz do projeto: bash script/00-GERAR-CHAVES.sh
# ============================================================

set -Eeuo pipefail

DIR="backend/src/main/resources/Keys"
mkdir -p "$DIR"

# Chave privada PKCS#8 (genpkey sempre gera nesse formato)
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out "$DIR/private_key.pem"

# Chave pública correspondente
openssl pkey -in "$DIR/private_key.pem" -pubout -out "$DIR/public_key.pem"

echo "Primeira linha da chave privada (tem que ser BEGIN PRIVATE KEY):"
head -n 1 "$DIR/private_key.pem"
echo "Primeira linha da chave pública (tem que ser BEGIN PUBLIC KEY):"
head -n 1 "$DIR/public_key.pem"
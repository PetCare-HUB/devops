#!/usr/bin/env bash
# ============================================================
# PETCARE HUB - SPRINT 4
# 02 - DEPLOY MANUAL DO .JAR (validação antes do CI/CD)
#
# Uso:
#   bash script/02-DEPLOY-MANUAL.sh ~/petcarehub-java-1.0.0.jar
#
# Depois que o CI/CD estiver pronto, quem faz o deploy é o
# pipeline. Este script serve só para validar a API na nuvem.
# ============================================================

set -Eeuo pipefail

RESOURCE_GROUP="${RESOURCE_GROUP:-petcare-rg}"
WEB_APP="${WEB_APP:-petcare-hub-api}"
JAR_FILE="${1:?ERRO: informe o caminho do .jar. Ex: bash script/02-DEPLOY-MANUAL.sh ~/petcarehub-java-1.0.0.jar}"

if [[ ! -f "$JAR_FILE" ]]; then
    echo "ERRO: arquivo não encontrado: $JAR_FILE"
    exit 1
fi

echo "=================================================="
echo " DEPLOY MANUAL"
echo "=================================================="
echo "Web App : $WEB_APP"
echo "JAR     : $JAR_FILE"
echo

az webapp deploy \
    --resource-group "$RESOURCE_GROUP" \
    --name "$WEB_APP" \
    --src-path "$JAR_FILE" \
    --type jar

HOST=$(az webapp show -g "$RESOURCE_GROUP" -n "$WEB_APP" --query defaultHostName -o tsv)

echo
echo "=================================================="
echo " DEPLOY ENVIADO"
echo "=================================================="
echo "A primeira inicialização leva ~2 minutos."
echo
echo "Swagger : https://$HOST/swagger-ui/index.html"
echo
echo "Ver o log da API subindo (Ctrl+C para sair):"
echo "az webapp log tail -g $RESOURCE_GROUP -n $WEB_APP"
echo "=================================================="

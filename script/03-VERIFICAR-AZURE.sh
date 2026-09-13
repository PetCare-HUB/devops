#!/bin/bash
set -e

RESOURCE_GROUP="${RESOURCE_GROUP:-petcare-rg}"
WEB_APP="${WEB_APP:-petcare-hub-api}"

echo "=============================================="
echo " PETCARE HUB - VERIFICAÇÃO"
echo "=============================================="

# ============================================================
# 1 - STATUS
# ============================================================

echo
echo "[1/5] Status do App Service:"

az webapp show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$WEB_APP" \
  --query "{name:name,state:state,host:defaultHostName,kind:kind}" \
  --output table

HOST=$(az webapp show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$WEB_APP" \
  --query "defaultHostName" \
  --output tsv)

if [ -z "$HOST" ]; then
    echo "ERRO: não foi possível obter o endereço público."
    exit 1
fi

# ============================================================
# 2 - URL
# ============================================================

echo
echo "[2/5] URL pública:"
echo "https://$HOST"

# ============================================================
# 3 - JAVA
# ============================================================

echo
echo "[3/5] Configuração Java:"

JAVA_VERSION=$(az webapp config show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$WEB_APP" \
  --query "javaVersion" \
  --output tsv)

JAVA_CONTAINER=$(az webapp config show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$WEB_APP" \
  --query "javaContainer" \
  --output tsv)

JAVA_CONTAINER_VERSION=$(az webapp config show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$WEB_APP" \
  --query "javaContainerVersion" \
  --output tsv)

echo "Java Version      : $JAVA_VERSION"
echo "Java Container    : $JAVA_CONTAINER"
echo "Container Version : $JAVA_CONTAINER_VERSION"

if [ "$JAVA_VERSION" != "17" ]; then
    echo "ERRO: Web App não está configurado com Java 17."
    exit 1
fi

echo "Java 17 validado."

# ============================================================
# 4 - TESTES HTTP
# ============================================================

echo
echo "[4/5] Testando aplicação..."

echo
echo "Teste /"
HTTP_ROOT=$(curl -L -s -o /dev/null -w "%{http_code}" --max-time 30 "https://$HOST/" || true)
echo "HTTP Status: $HTTP_ROOT"

echo
echo "Teste /v3/api-docs"
HTTP_API_DOCS=$(curl -L -s -o /dev/null -w "%{http_code}" --max-time 30 "https://$HOST/v3/api-docs" || true)
echo "HTTP Status: $HTTP_API_DOCS"

echo
echo "Teste /swagger-ui/index.html"
HTTP_SWAGGER=$(curl -L -s -o /dev/null -w "%{http_code}" --max-time 30 "https://$HOST/swagger-ui/index.html" || true)
echo "HTTP Status: $HTTP_SWAGGER"

# ============================================================
# RESULTADO
# ============================================================

echo

if [ "$HTTP_ROOT" = "200" ]; then
    echo "OK - aplicação respondeu em /."
else
    echo "ATENÇÃO - / retornou HTTP $HTTP_ROOT."
fi

if [ "$HTTP_API_DOCS" = "200" ]; then
    echo "OK - API Docs respondeu corretamente."
else
    echo "ATENÇÃO - API Docs retornou HTTP $HTTP_API_DOCS."
fi

if [ "$HTTP_SWAGGER" = "200" ]; then
    echo "OK - Swagger respondeu corretamente."
else
    echo "ATENÇÃO - Swagger retornou HTTP $HTTP_SWAGGER."
fi

# ============================================================
# 5 - LOGS
# ============================================================

echo
echo "[5/5] Logs"

echo
echo "Para visualizar os logs em tempo real:"
echo
echo "az webapp log tail \\"
echo "  --resource-group \"$RESOURCE_GROUP\" \\"
echo "  --name \"$WEB_APP\""

echo
echo "=============================================="
echo " VERIFICAÇÃO FINALIZADA"
echo "=============================================="
echo
echo "Aplicação:"
echo "https://$HOST"
echo
echo "Swagger:"
echo "https://$HOST/swagger-ui/index.html"
echo
echo "OpenAPI:"
echo "https://$HOST/v3/api-docs"
echo
echo "Java:"
echo "$JAVA_VERSION"
echo
echo "=============================================="

#!/bin/bash

set -e

RESOURCE_GROUP="petcare-rg"
LOCATION="brazilsouth"

SQL_SERVER="petcare-sql-server"
SQL_DATABASE="petcare-db"
SQL_ADMIN="user-PetCareHub"
SQL_PASSWORD="Petcare@123456"

APP_PLAN="petcare-plan"
WEB_APP="petcare-hub-api"

echo "=============================================="
echo " PETCARE HUB - CRIAÇÃO DA INFRAESTRUTURA"
echo "=============================================="
echo "Resource Group : $RESOURCE_GROUP"
echo "Location       : $LOCATION"
echo "SQL Server     : $SQL_SERVER"
echo "SQL Database   : $SQL_DATABASE"
echo "App Service    : $WEB_APP"
echo "Java           : 17"
echo "App Service OS : Windows"
echo "=============================================="

# ============================================================
# 0 - LOGIN
# ============================================================

echo
echo "[0/6] Verificando login no Azure..."
az account show >/dev/null 2>&1 || az login

# ============================================================
# 1 - RESOURCE GROUP
# ============================================================

echo
echo "[1/6] Criando Resource Group..."

if az group show --name "$RESOURCE_GROUP" >/dev/null 2>&1; then
    echo "Resource Group já existe: $RESOURCE_GROUP"
else
    az group create \
      --name "$RESOURCE_GROUP" \
      --location "$LOCATION"
fi

# ============================================================
# 2 - SQL SERVER
# ============================================================

echo
echo "[2/6] Criando Azure SQL Server..."

if az sql server show \
  --name "$SQL_SERVER" \
  --resource-group "$RESOURCE_GROUP" >/dev/null 2>&1; then

    echo "SQL Server já existe: $SQL_SERVER"

else

    az sql server create \
      --name "$SQL_SERVER" \
      --resource-group "$RESOURCE_GROUP" \
      --location "$LOCATION" \
      --admin-user "$SQL_ADMIN" \
      --admin-password "$SQL_PASSWORD" \
      --enable-public-network true

fi

# ============================================================
# 3 - SQL DATABASE
# ============================================================

echo
echo "[3/6] Criando Azure SQL Database..."

if az sql db show \
  --resource-group "$RESOURCE_GROUP" \
  --server "$SQL_SERVER" \
  --name "$SQL_DATABASE" >/dev/null 2>&1; then

    echo "SQL Database já existe: $SQL_DATABASE"

else

    az sql db create \
      --resource-group "$RESOURCE_GROUP" \
      --server "$SQL_SERVER" \
      --name "$SQL_DATABASE" \
      --service-objective Basic \
      --backup-storage-redundancy Local \
      --zone-redundant false

fi

# ============================================================
# 4 - FIREWALL
# ============================================================

echo
echo "[4/6] Configurando Firewall do Azure SQL..."

if az sql server firewall-rule show \
  --resource-group "$RESOURCE_GROUP" \
  --server "$SQL_SERVER" \
  --name "liberaAzureServices" >/dev/null 2>&1; then

    echo "Regra liberaAzureServices já existe."

else

    az sql server firewall-rule create \
      --resource-group "$RESOURCE_GROUP" \
      --server "$SQL_SERVER" \
      --name "liberaAzureServices" \
      --start-ip-address "0.0.0.0" \
      --end-ip-address "0.0.0.0"

fi

MY_IP=$(curl -s https://api.ipify.org)

if [ -z "$MY_IP" ]; then
    echo "ERRO: Não foi possível detectar o IP público."
    exit 1
fi

echo "IP público detectado: $MY_IP"

az sql server firewall-rule create \
  --resource-group "$RESOURCE_GROUP" \
  --server "$SQL_SERVER" \
  --name "AllowMyIP" \
  --start-ip-address "$MY_IP" \
  --end-ip-address "$MY_IP" \
  >/dev/null

# ============================================================
# 5 - APP SERVICE PLAN
# ============================================================

echo
echo "[5/6] Criando App Service Plan Windows..."

if az appservice plan show \
  --name "$APP_PLAN" \
  --resource-group "$RESOURCE_GROUP" >/dev/null 2>&1; then

    echo "App Service Plan já existe: $APP_PLAN"

else

    az appservice plan create \
      --name "$APP_PLAN" \
      --resource-group "$RESOURCE_GROUP" \
      --location "$LOCATION" \
      --sku B1 \
      --is-linux false

fi

echo
echo "Validando App Service Plan..."

PLAN_KIND=$(az appservice plan show \
  --name "$APP_PLAN" \
  --resource-group "$RESOURCE_GROUP" \
  --query "kind" \
  --output tsv)

if [ "$PLAN_KIND" != "app" ]; then
    echo "ERRO: App Service Plan não possui kind=app."
    echo "Kind atual: $PLAN_KIND"
    exit 1
fi

echo "App Service Plan validado."

# ============================================================
# 6 - APP SERVICE
# ============================================================

echo
echo "[6/6] Criando Azure App Service Java 17..."

if az webapp show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$WEB_APP" >/dev/null 2>&1; then

    echo "Web App já existe: $WEB_APP"

else

    az webapp create \
      --resource-group "$RESOURCE_GROUP" \
      --plan "$APP_PLAN" \
      --name "$WEB_APP" \
      --runtime "JAVA:17"

fi

echo
echo "Configurando Java 17 no Web App..."

az webapp config set \
  --resource-group "$RESOURCE_GROUP" \
  --name "$WEB_APP" \
  --java-version 17 \
  --java-container JAVA \
  --java-container-version SE

# ============================================================
# VALIDAÇÃO FINAL
# ============================================================

HOST=$(az webapp show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$WEB_APP" \
  --query "defaultHostName" \
  --output tsv)

WEBAPP_KIND=$(az webapp show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$WEB_APP" \
  --query "kind" \
  --output tsv)

WEBAPP_JAVA=$(az webapp config show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$WEB_APP" \
  --query "javaVersion" \
  --output tsv)

echo
echo "=============================================="
echo " INFRAESTRUTURA CRIADA COM SUCESSO"
echo "=============================================="
echo
echo "Aplicação:"
echo "https://$HOST"
echo
echo "Banco:"
echo "$SQL_SERVER.database.windows.net"
echo
echo "Database:"
echo "$SQL_DATABASE"
echo
echo "App Service:"
echo "$WEB_APP"
echo
echo "App Service Plan:"
echo "$APP_PLAN"
echo
echo "Runtime:"
echo "Java $WEBAPP_JAVA - Windows"
echo
echo "Web App kind:"
echo "$WEBAPP_KIND"
echo
echo "=============================================="

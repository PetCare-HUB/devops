#!/usr/bin/env bash
# ============================================================
# PETCARE HUB - SPRINT 4
# 01 - CRIAR INFRAESTRUTURA NO AZURE (via Azure CLI)
#
# Cria: Resource Group, Azure SQL Server, Azure SQL Database,
#       Firewall, App Service Plan LINUX e Web App Java 17.
# Também configura a conexão da API com o banco.
#
# A senha NÃO fica no código. Antes de rodar:
#   export SQL_PASSWORD='SuaSenhaForte@2026'
#   bash script/01-INFRAESTRUTURA-AZURE.sh
# ============================================================

set -Eeuo pipefail

# ------------------------------------------------------------
# CONFIGURAÇÕES (podem ser trocadas com export antes de rodar)
# ------------------------------------------------------------
RESOURCE_GROUP="${RESOURCE_GROUP:-petcare-rg}"
LOCATION="${LOCATION:-brazilsouth}"

SQL_SERVER="${SQL_SERVER:-petcare-sql-server}"
SQL_DATABASE="${SQL_DATABASE:-petcare-db}"
SQL_ADMIN="${SQL_ADMIN:-user-PetCareHub}"

#coloca sua senha depois
SQL_PASSWORD="${SQL_PASSWORD:?ERRO: defina antes -> export SQL_PASSWORD='SuaSenha'}"

APP_PLAN="${APP_PLAN:-petcare-plan}"
WEB_APP="${WEB_APP:-petcare-hub-api}"
RUNTIME="JAVA:17-java17"

echo "=================================================="
echo " PETCARE HUB - CRIAÇÃO DA INFRAESTRUTURA AZURE"
echo "=================================================="
echo "Resource Group : $RESOURCE_GROUP"
echo "Região         : $LOCATION"
echo "SQL Server     : $SQL_SERVER"
echo "Database       : $SQL_DATABASE"
echo "Web App        : $WEB_APP (Linux / Java 17)"
echo "=================================================="

command -v az >/dev/null 2>&1 || { echo "ERRO: Azure CLI não instalado."; exit 1; }

# ------------------------------------------------------------
# 0 - LOGIN
# ------------------------------------------------------------
echo; echo "[0/7] Verificando login..."
az account show >/dev/null 2>&1 || az login
echo "Assinatura: $(az account show --query name -o tsv)"

# ------------------------------------------------------------
# 1 - RESOURCE GROUP
# ------------------------------------------------------------
echo; echo "[1/7] Resource Group..."
if [[ "$(az group exists --name "$RESOURCE_GROUP")" == "true" ]]; then
    echo "Já existe."
else
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none
    echo "Criado."
fi

# ------------------------------------------------------------
# 2 - AZURE SQL SERVER
# ------------------------------------------------------------
echo; echo "[2/7] Azure SQL Server..."
if az sql server show -g "$RESOURCE_GROUP" -n "$SQL_SERVER" >/dev/null 2>&1; then
    echo "Já existe."
else
    az sql server create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$SQL_SERVER" \
        --location "$LOCATION" \
        --admin-user "$SQL_ADMIN" \
        --admin-password "$SQL_PASSWORD" \
        --enable-public-network true \
        --output none
    echo "Criado."
fi

# ------------------------------------------------------------
# 3 - AZURE SQL DATABASE
# ------------------------------------------------------------
echo; echo "[3/7] Azure SQL Database..."
if az sql db show -g "$RESOURCE_GROUP" -s "$SQL_SERVER" -n "$SQL_DATABASE" >/dev/null 2>&1; then
    echo "Já existe."
else
    az sql db create \
        --resource-group "$RESOURCE_GROUP" \
        --server "$SQL_SERVER" \
        --name "$SQL_DATABASE" \
        --service-objective Basic \
        --backup-storage-redundancy Local \
        --output none
    echo "Criado."
fi

# ------------------------------------------------------------
# 4 - FIREWALL (libera serviços Azure: Web App e Query Editor)
# ------------------------------------------------------------
echo; echo "[4/7] Firewall..."
if ! az sql server firewall-rule show -g "$RESOURCE_GROUP" -s "$SQL_SERVER" -n "AllowAzureServices" >/dev/null 2>&1; then
    az sql server firewall-rule create \
        --resource-group "$RESOURCE_GROUP" \
        --server "$SQL_SERVER" \
        --name "AllowAzureServices" \
        --start-ip-address 0.0.0.0 \
        --end-ip-address 0.0.0.0 \
        --output none
fi
echo "Serviços Azure liberados."

# ------------------------------------------------------------
# 5 - APP SERVICE PLAN (LINUX)
# ------------------------------------------------------------
echo; echo "[5/7] App Service Plan Linux..."
if az appservice plan show -g "$RESOURCE_GROUP" -n "$APP_PLAN" >/dev/null 2>&1; then
    echo "Já existe."
else
    az appservice plan create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$APP_PLAN" \
        --location "$LOCATION" \
        --sku B1 \
        --is-linux \
        --output none
    echo "Criado."
fi

# ------------------------------------------------------------
# 6 - WEB APP JAVA 17
# ------------------------------------------------------------
echo; echo "[6/7] Web App Java 17..."
if az webapp show -g "$RESOURCE_GROUP" -n "$WEB_APP" >/dev/null 2>&1; then
    echo "Já existe."
else
    az webapp create \
        --resource-group "$RESOURCE_GROUP" \
        --plan "$APP_PLAN" \
        --name "$WEB_APP" \
        --runtime "$RUNTIME" \
        --output none
    echo "Criado."
fi

# ------------------------------------------------------------
# 7 - CONEXÃO DA API COM O BANCO (variáveis de ambiente)
# ------------------------------------------------------------
echo; echo "[7/7] Configurando conexão com o banco..."
DB_URL="jdbc:sqlserver://${SQL_SERVER}.database.windows.net:1433;database=${SQL_DATABASE};encrypt=true;trustServerCertificate=false;loginTimeout=30"

az webapp config appsettings set \
    --resource-group "$RESOURCE_GROUP" \
    --name "$WEB_APP" \
    --settings DB_URL="$DB_URL" DB_USERNAME="$SQL_ADMIN" DB_PASSWORD="$SQL_PASSWORD" \
    --output none
echo "Variáveis DB_URL, DB_USERNAME e DB_PASSWORD configuradas."

# ------------------------------------------------------------
# RESULTADO
# ------------------------------------------------------------
HOST=$(az webapp show -g "$RESOURCE_GROUP" -n "$WEB_APP" --query defaultHostName -o tsv)
RUNTIME_ATUAL=$(az webapp config show -g "$RESOURCE_GROUP" -n "$WEB_APP" --query linuxFxVersion -o tsv)

echo
echo "=================================================="
echo " INFRAESTRUTURA CRIADA"
echo "=================================================="
echo "API      : https://$HOST"
echo "Runtime  : $RUNTIME_ATUAL"
echo "Banco    : ${SQL_SERVER}.database.windows.net / $SQL_DATABASE"
echo
echo "DB_URL (guarde para o pipeline):"
echo "$DB_URL"
echo "=================================================="
echo " PRÓXIMO: bash script/02-DEPLOY-MANUAL.sh caminho/do/arquivo.jar"
echo "=================================================="

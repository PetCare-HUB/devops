#!/bin/bash

set -e

RESOURCE_GROUP="${RESOURCE_GROUP:-petcare-rg}"
SQL_SERVER="${SQL_SERVER:-petcare-sql-server}"
SQL_DATABASE="${SQL_DATABASE:-petcare-db}"
WEB_APP="${WEB_APP:-petcare-hub-api}"
SQL_ADMIN="${SQL_ADMIN:-user-PetCareHub}"
SQL_PASSWORD="Petcare@123456"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKEND_DIR="$PROJECT_ROOT/backend"

echo "=============================================="
echo " PETCARE HUB - CONFIGURAÇÃO E DEPLOY"
echo "=============================================="
echo "Projeto : $PROJECT_ROOT"
echo "Backend : $BACKEND_DIR"
echo "Web App : $WEB_APP"
echo

# ============================================================
# CREDENCIAL
# ============================================================

# ============================================================
# 0 - VALIDAÇÕES
# ============================================================

echo "[0/4] Validando recursos do Azure..."

az sql server show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$SQL_SERVER" \
  --output none

echo "Azure SQL Server encontrado."

az sql db show \
  --resource-group "$RESOURCE_GROUP" \
  --server "$SQL_SERVER" \
  --name "$SQL_DATABASE" \
  --output none

echo "Azure SQL Database encontrado."

az webapp show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$WEB_APP" \
  --output none

echo "Azure App Service encontrado."

if [ ! -d "$BACKEND_DIR" ]; then
    echo "ERRO: diretório backend não encontrado:"
    echo "$BACKEND_DIR"
    exit 1
fi

if [ ! -x "$BACKEND_DIR/mvnw" ]; then
    echo "ERRO: mvnw não possui permissão de execução."
    echo "Execute: chmod +x backend/mvnw"
    exit 1
fi

# ============================================================
# CONNECTION STRING
# ============================================================

SQL_HOST="${SQL_SERVER}.database.windows.net"

DB_URL="jdbc:sqlserver://${SQL_HOST}:1433;database=${SQL_DATABASE};encrypt=true;trustServerCertificate=false;loginTimeout=30"

# ============================================================
# 1 - APP SETTINGS
# ============================================================

echo
echo "[1/4] Configurando variáveis de ambiente..."

az webapp config appsettings set \
  --resource-group "$RESOURCE_GROUP" \
  --name "$WEB_APP" \
  --settings \
    DB_URL="$DB_URL" \
    DB_USERNAME="$SQL_ADMIN" \
    DB_PASSWORD="$SQL_PASSWORD" \
    SPRING_PROFILES_ACTIVE=prod \
  >/dev/null

echo "Variáveis de ambiente configuradas."

# ============================================================
# 2 - JAVA 17
# ============================================================

echo
echo "[2/4] Validando configuração do App Service..."

WEBAPP_JAVA_VERSION=$(az webapp config show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$WEB_APP" \
  --query "javaVersion" \
  --output tsv)

WEBAPP_JAVA_CONTAINER=$(az webapp config show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$WEB_APP" \
  --query "javaContainer" \
  --output tsv)

WEBAPP_JAVA_CONTAINER_VERSION=$(az webapp config show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$WEB_APP" \
  --query "javaContainerVersion" \
  --output tsv)

WEBAPP_KIND=$(az webapp show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$WEB_APP" \
  --query "kind" \
  --output tsv)

echo "Kind                  : $WEBAPP_KIND"
echo "Java Version          : $WEBAPP_JAVA_VERSION"
echo "Java Container        : $WEBAPP_JAVA_CONTAINER"
echo "Container Version     : $WEBAPP_JAVA_CONTAINER_VERSION"

if [ "$WEBAPP_KIND" != "app" ]; then
    echo "ERRO: App Service não possui kind=app."
    exit 1
fi

if [ "$WEBAPP_JAVA_VERSION" != "17" ]; then
    echo "ERRO: App Service não está configurado com Java 17."
    exit 1
fi

echo
echo "App Service Windows + Java 17 validado."

# ============================================================
# 3 - BUILD
# ============================================================

echo
echo "[3/4] Gerando JAR..."

cd "$BACKEND_DIR"

echo "Diretório atual:"
pwd

./mvnw clean package -DskipTests

JAR_FILE=$(find target \
  -maxdepth 1 \
  -type f \
  -name "*.jar" \
  ! -name "*-plain.jar" \
  | head -n 1)

if [ -z "$JAR_FILE" ]; then
    echo "ERRO: nenhum JAR executável encontrado em:"
    echo "$BACKEND_DIR/target/"
    exit 1
fi

echo
echo "JAR encontrado:"
echo "$JAR_FILE"

# ============================================================
# 4 - DEPLOY
# ============================================================

echo
echo "[4/4] Fazendo deploy no Azure App Service..."

az webapp deploy \
  --resource-group "$RESOURCE_GROUP" \
  --name "$WEB_APP" \
  --src-path "$JAR_FILE" \
  --type jar

# ============================================================
# STARTUP COMMAND
# ============================================================

echo
echo "Configurando comando de inicialização..."

az webapp config set \
  --resource-group "$RESOURCE_GROUP" \
  --name "$WEB_APP" \
  --startup-file 'java -jar D:\home\site\wwwroot\app.jar' \
  >/dev/null

echo "Startup command configurado."

# ============================================================
# RESTART
# ============================================================

echo
echo "Reiniciando Web App..."

az webapp restart \
  --resource-group "$RESOURCE_GROUP" \
  --name "$WEB_APP"

# ============================================================
# RESULTADO
# ============================================================

echo
echo "=============================================="
echo " DEPLOY CONCLUÍDO"
echo "=============================================="
echo
echo "Aplicação:"
echo "https://${WEB_APP}.azurewebsites.net"
echo
echo "Swagger:"
echo "https://${WEB_APP}.azurewebsites.net/swagger-ui/index.html"
echo
echo "API Docs:"
echo "https://${WEB_APP}.azurewebsites.net/v3/api-docs"
echo
echo "Banco:"
echo "${SQL_HOST}"
echo
echo "Database:"
echo "${SQL_DATABASE}"
echo
echo "Java:"
echo "${WEBAPP_JAVA_VERSION}"
echo
echo "=============================================="

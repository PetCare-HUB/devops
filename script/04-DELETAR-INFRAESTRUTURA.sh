#!/bin/bash

# ============================================================
# PETCARE HUB - SPRINT 3
# 99 - DELETAR TODA A INFRAESTRUTURA
# ============================================================

set -e

RESOURCE_GROUP="${RESOURCE_GROUP:-petcare-rg}"

if ! az group show --name "$RESOURCE_GROUP" >/dev/null 2>&1; then
    exit 0
fi

az group delete \
  --name "$RESOURCE_GROUP" \
  --yes \
  --no-wait

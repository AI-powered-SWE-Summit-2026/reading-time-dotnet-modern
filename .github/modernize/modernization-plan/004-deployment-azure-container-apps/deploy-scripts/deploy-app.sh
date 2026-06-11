#!/usr/bin/env bash
# deploy-app.sh — Build and deploy ReadingTimeDemo image to Azure Container Apps
# Run this after infrastructure is provisioned with infra/deploy.sh
# Usage: ./deploy-scripts/deploy-app.sh <RESOURCE_GROUP> <ACR_NAME> <CONTAINER_APP_NAME> [IMAGE_TAG]
set -euo pipefail

RESOURCE_GROUP="${1:?Usage: $0 <RESOURCE_GROUP> <ACR_NAME> <CONTAINER_APP_NAME> [IMAGE_TAG]}"
ACR_NAME="${2:?ACR name required}"
CONTAINER_APP_NAME="${3:?Container App name required}"
IMAGE_TAG="${4:-latest}"
IMAGE_NAME="readingtimedemo"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

echo "============================================================"
echo "  ReadingTimeDemo — Container App Image Deployment"
echo "============================================================"
echo "  Resource Group  : $RESOURCE_GROUP"
echo "  ACR Name        : $ACR_NAME"
echo "  Container App   : $CONTAINER_APP_NAME"
echo "  Image Tag       : $IMAGE_TAG"
echo "  Repo Root       : $REPO_ROOT"
echo "============================================================"

# ── Build & push image via az acr build ─────────────────────────────────────
echo ""
echo "[1/2] Building and pushing image to ACR: ${ACR_NAME}..."
az acr build \
  --registry "$ACR_NAME" \
  --image "${IMAGE_NAME}:${IMAGE_TAG}" \
  --file "$REPO_ROOT/src/ReadingTimeDemo/Dockerfile" \
  "$REPO_ROOT/src/ReadingTimeDemo" \
  --platform linux/amd64

FULL_IMAGE="${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}"
echo "Image pushed: $FULL_IMAGE"

# ── Update Container App with new image ──────────────────────────────────────
echo ""
echo "[2/2] Updating Container App '$CONTAINER_APP_NAME' with new image..."
az containerapp update \
  --name "$CONTAINER_APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --image "$FULL_IMAGE" \
  --output table

# ── Get and display app URL ───────────────────────────────────────────────────
APP_FQDN=$(az containerapp show \
  --name "$CONTAINER_APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query "properties.configuration.ingress.fqdn" \
  --output tsv)

echo ""
echo "============================================================"
echo "  Deployment Complete!"
echo "  Application URL : https://$APP_FQDN"
echo "============================================================"

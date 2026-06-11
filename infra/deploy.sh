#!/usr/bin/env bash
# deploy.sh — Provision and deploy ReadingTimeDemo to Azure Container Apps
# Usage: ./infra/deploy.sh [RESOURCE_GROUP] [LOCATION] [ENVIRONMENT_NAME]
set -euo pipefail

RESOURCE_GROUP="${1:-rg-readingtimedemo}"
LOCATION="${2:-eastus}"
ENVIRONMENT_NAME="${3:-prod}"
SUBSCRIPTION_ID="5b97b8de-e4f7-4787-a860-bcdc1130e599"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_TAG="${IMAGE_TAG:-latest}"

echo "============================================================"
echo "  ReadingTimeDemo — Azure Container Apps Deployment"
echo "============================================================"
echo "  Resource Group : $RESOURCE_GROUP"
echo "  Location       : $LOCATION"
echo "  Environment    : $ENVIRONMENT_NAME"
echo "  Subscription   : $SUBSCRIPTION_ID"
echo "============================================================"

# ── Step 1: Set subscription ─────────────────────────────────────────────────
echo ""
echo "[1/6] Setting Azure subscription..."
az account set --subscription "$SUBSCRIPTION_ID"
az account show --query "{Name:name, ID:id}" -o table

# ── Step 2: Create resource group ────────────────────────────────────────────
echo ""
echo "[2/6] Creating/verifying resource group '$RESOURCE_GROUP' in '$LOCATION'..."
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --tags project=ReadingTimeDemo environment="$ENVIRONMENT_NAME" \
  --output table

# ── Step 3: Validate Bicep template ──────────────────────────────────────────
echo ""
echo "[3/6] Validating Bicep template..."
az deployment group validate \
  --resource-group "$RESOURCE_GROUP" \
  --template-file "$SCRIPT_DIR/main.bicep" \
  --parameters "$SCRIPT_DIR/main.parameters.json" \
  --parameters environmentName="$ENVIRONMENT_NAME" location="$LOCATION" \
  --output table

# ── Step 4: Provision Azure infrastructure ───────────────────────────────────
echo ""
echo "[4/6] Provisioning Azure infrastructure (this may take 5-10 minutes)..."
DEPLOYMENT_OUTPUT=$(az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --template-file "$SCRIPT_DIR/main.bicep" \
  --parameters "$SCRIPT_DIR/main.parameters.json" \
  --parameters environmentName="$ENVIRONMENT_NAME" location="$LOCATION" \
  --name "readingtimedemo-$(date +%Y%m%d%H%M%S)" \
  --output json)

echo "Infrastructure provisioning complete."

# Extract outputs
ACR_NAME=$(echo "$DEPLOYMENT_OUTPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['properties']['outputs']['containerRegistryName']['value'])")
ACR_LOGIN_SERVER=$(echo "$DEPLOYMENT_OUTPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['properties']['outputs']['containerRegistryLoginServer']['value'])")
CONTAINER_APP_NAME=$(echo "$DEPLOYMENT_OUTPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['properties']['outputs']['containerAppName']['value'])")
CONTAINER_APP_FQDN=$(echo "$DEPLOYMENT_OUTPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['properties']['outputs']['containerAppFqdn']['value'])")
MI_CLIENT_ID=$(echo "$DEPLOYMENT_OUTPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['properties']['outputs']['managedIdentityClientId']['value'])")
APP_CONFIG_ENDPOINT=$(echo "$DEPLOYMENT_OUTPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['properties']['outputs']['appConfigEndpoint']['value'])")
STORAGE_URI=$(echo "$DEPLOYMENT_OUTPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['properties']['outputs']['storageAccountUri']['value'])")

echo ""
echo "Provisioned resources:"
echo "  ACR Name         : $ACR_NAME"
echo "  ACR Login Server : $ACR_LOGIN_SERVER"
echo "  Container App    : $CONTAINER_APP_NAME"
echo "  App FQDN         : $CONTAINER_APP_FQDN"
echo "  MI Client ID     : $MI_CLIENT_ID"
echo "  App Config       : $APP_CONFIG_ENDPOINT"
echo "  Storage URI      : $STORAGE_URI"

# ── Step 5: Build & push Docker image to ACR ─────────────────────────────────
echo ""
echo "[5/6] Building and pushing Docker image to ACR..."
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
IMAGE_NAME="readingtimedemo"
FULL_IMAGE="${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"

az acr build \
  --registry "$ACR_NAME" \
  --image "${IMAGE_NAME}:${IMAGE_TAG}" \
  --file "$REPO_ROOT/src/ReadingTimeDemo/Dockerfile" \
  "$REPO_ROOT/src/ReadingTimeDemo" \
  --platform linux/amd64

echo "Image pushed: $FULL_IMAGE"

# ── Step 6: Update Container App with new image ───────────────────────────────
echo ""
echo "[6/6] Updating Container App with application image..."
az containerapp update \
  --name "$CONTAINER_APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --image "$FULL_IMAGE" \
  --output table

echo ""
echo "============================================================"
echo "  Deployment Complete!"
echo "============================================================"
echo "  Application URL : https://$CONTAINER_APP_FQDN"
echo "  Container App   : $CONTAINER_APP_NAME"
echo "  Resource Group  : $RESOURCE_GROUP"
echo "============================================================"

# ReadingTimeDemo — Azure Infrastructure

## Overview

This directory contains Bicep Infrastructure as Code (IaC) templates to provision all Azure resources required for the **ReadingTimeDemo** ASP.NET Core 10 application on **Azure Container Apps**.

## Architecture

| Resource | Name Pattern | Region | Purpose |
|---|---|---|---|
| User-Assigned Managed Identity | `azmi{token}` | eastus | Identity for all Azure service access |
| Azure Container Registry | `azcr{token}` | eastus | Stores Docker images |
| Log Analytics Workspace | `azlaw{token}` | eastus | Centralized logging |
| Application Insights | `azai{token}` | eastus | Application telemetry |
| Key Vault | `azkv{token}` | eastus | Secrets storage (App Insights key) |
| App Configuration | `azac{token}` | eastus | Externalized app settings |
| Storage Account | `azst{token}` | eastus | Blob storage for static assets |
| Container Apps Environment | `azce{token}` | eastus | ACA hosting environment |
| Container App | `azca{token}` | eastus | Runs ReadingTimeDemo container |

> **Token**: `uniqueString(subscription().id, resourceGroup().id, location, environmentName)`

## Prerequisites

- Azure CLI 2.60+ installed (`az --version`)
- Bicep CLI (`az bicep install`)
- Subscription: `5b97b8de-e4f7-4787-a860-bcdc1130e599`

## Deployment

### Linux / macOS

```bash
chmod +x infra/deploy.sh
./infra/deploy.sh [resource-group] [location] [environment-name]

# Example:
./infra/deploy.sh rg-readingtimedemo eastus prod
```

### Windows (PowerShell)

```powershell
.\infra\deploy.ps1 -ResourceGroup rg-readingtimedemo -Location eastus -EnvironmentName prod
```

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `environmentName` | `prod` | Used in resource naming token |
| `location` | `eastus` | Azure region for all resources |
| `staticAssetsContainerName` | `static-assets` | Blob container for static files |

## Post-Deployment

After provisioning, the Container App runs the placeholder image (`containerapps-helloworld`). The deploy script automatically builds and pushes the real application image via `az acr build` and updates the Container App.

### Manual image update

```bash
ACR_NAME=<your-acr-name>
CONTAINER_APP=<your-container-app-name>
RG=rg-readingtimedemo

az acr build --registry $ACR_NAME \
  --image readingtimedemo:latest \
  --file src/ReadingTimeDemo/Dockerfile \
  src/ReadingTimeDemo

az containerapp update \
  --name $CONTAINER_APP \
  --resource-group $RG \
  --image ${ACR_NAME}.azurecr.io/readingtimedemo:latest
```

## Security

- **Managed Identity**: All Azure service connections use User-Assigned Managed Identity (no passwords/keys)
- **ACR**: Admin user disabled; AcrPull role assigned to MI
- **Storage**: Local auth and anonymous blob access disabled
- **Key Vault**: RBAC auth; Secrets Officer role assigned to MI
- **App Configuration**: Data Reader role assigned to MI
- **Container App**: Runs as non-root user (UID 1001)

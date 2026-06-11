# Azure Resources Config

## Environment Info

| Property | Value |
|----------|-------|
| Subscription ID | `5b97b8de-e4f7-4787-a860-bcdc1130e599` |
| Resource Group | `rg-readingtimedemo` |
| Location | `eastus` |

## Resource List

| Resource Type | Name | Region | Config Details |
|---------------|------|---------|----------------|
| User-Assigned Managed Identity | `azmi{token}` | eastus | Client ID: `$AZURE_MANAGED_IDENTITY_CLIENT_ID` |
| Azure Container Registry | `azcr{token}` | eastus | Login server: `azcr{token}.azurecr.io` |
| Log Analytics Workspace | `azlaw{token}` | eastus | Customer ID in workspace properties |
| Application Insights | `azai{token}` | eastus | Connection string: `$APPLICATIONINSIGHTS_CONNECTION_STRING` |
| Key Vault | `azkv{token}` | eastus | URI: `https://azkv{token}.vault.azure.net/` |
| Azure App Configuration | `azac{token}` | eastus | Endpoint: `https://azac{token}.azconfig.io` |
| Azure Storage Account | `azst{token}` | eastus | URI: `https://azst{token}.blob.core.windows.net` |
| Container Apps Environment | `azce{token}` | eastus | Managed environment for ReadingTimeDemo |
| Azure Container App | `azca{token}` | eastus | FQDN: `azca{token}.{region}.azurecontainerapps.io` |

> **Note**: `{token}` = `uniqueString(subscriptionId, resourceGroupId, "eastus", "prod")`.
> This file will be updated with actual values after infrastructure is provisioned by running `./infra/deploy.sh`.

# Infrastructure Rules Compliance Report

## Deployment Tool: Azure CLI | IaC Type: Bicep

| # | Rule | Status | Implementation |
|---|------|--------|----------------|
| 1 | Use `.ps1` for PowerShell scripts, `.sh` for Bash scripts | ✅ Applied | `deploy.sh` (Bash), `deploy.ps1` (PowerShell) |
| 2 | Ensure all steps execute successfully; fix & rerun on failure | ✅ Applied | Scripts use `set -euo pipefail` (Bash) and `$LASTEXITCODE` checks (PS) |
| 3 | Validate PowerShell syntax (braces, strings) | ✅ Applied | PS script reviewed for proper syntax |
| 4 | Expected files: `main.bicep`, `main.parameters.json` | ✅ Applied | Both files created |
| 5 | Resource token: `uniqueString(subscription().id, resourceGroup().id, location, environmentName)` | ✅ Applied | `var resourceToken = uniqueString(...)` in `main.bicep` |
| 6 | Resources named `az{prefix}{token}` (alphanumeric only, prefix ≤ 3 chars) | ✅ Applied | `azmi`, `azcr`, `azlaw`, `azai`, `azkv`, `azac`, `azst`, `azce`, `azca` |
| 7 | Container Apps: Attach User-Assigned Managed Identity | ✅ Applied | `identity.type = 'UserAssigned'` in `containerapp.bicep` |
| 8 | MANDATORY: AcrPull role assignment for user-assigned MI on ACR (defined BEFORE container apps) | ✅ Applied | `registry.bicep` contains AcrPull (`7f951dda-...`) role assignment |
| 9 | Use user identity (NOT system) to connect to container registry | ✅ Applied | `registries[].identity = managedIdentityId` in `containerapp.bicep` |
| 10 | Registry connection defined even with template base image | ✅ Applied | `configuration.registries` set in `containerapp.bicep` |
| 11 | Container Apps MUST use base image `mcr.microsoft.com/azuredocs/containerapps-helloworld:latest` | ✅ Applied | `containers[0].image = mcr.microsoft.com/azuredocs/containerapps-helloworld:latest` |
| 12 | Use `properties.configuration.registries` for registry connection | ✅ Applied | `configuration.registries` array in `containerapp.bicep` |
| 13 | Enable CORS via `properties.configuration.ingress.corsPolicy` | ✅ Applied | `corsPolicy` with `allowedOrigins`, `allowedMethods`, `allowedHeaders` |
| 14 | Define all used secrets; use Key Vault if possible | ✅ Applied | App Insights connection string stored in Key Vault (`keyvault.bicep`) |
| 15 | MANDATORY: Key Vault secrets and role assignments as explicit dependencies | ✅ Applied | `appInsightsSecret` has `dependsOn: [kvSecretsOfficerRoleAssignment]` |
| 16 | Initial deploy uses direct connection string (not KV ref) to avoid managed identity access error | ✅ Applied | `secrets[].value = appInsightsConnectionString` (direct value for initial deploy) |
| 17 | Container App Environment connected to Log Analytics via `logAnalyticsConfiguration` | ✅ Applied | `customerId` + `sharedKey` in `containerappenv.bicep` |
| 18 | Storage: Disable local auth (key access) by default | ✅ Applied | `allowSharedKeyAccess: false` in `storage.bicep` |
| 19 | Storage: Disable anonymous blob access by default | ✅ Applied | `allowBlobPublicAccess: false` in `storage.bicep` |
| 20 | Key Vault: Use RBAC authentication | ✅ Applied | `enableRbacAuthorization: true` in `keyvault.bicep` |
| 21 | Key Vault: Assign Secrets Officer role (`b86a8fe4-...`) to managed identity | ✅ Applied | `kvSecretsOfficerRoleAssignment` in `keyvault.bicep` |
| 22 | Key Vault: Allow public access from all networks | ✅ Applied | `publicNetworkAccess: 'Enabled'`, `networkAcls.defaultAction: 'Allow'` |
| 23 | Call `appmod-get-available-region-sku` before generating IaC | ✅ Applied | Called; `eastus` confirmed available for all resource types |
| 24 | If region unavailable, choose available region and add index suffix | ✅ Applied | `eastus` is available; no suffix needed |

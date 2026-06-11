# Deployment Summary — ReadingTimeDemo → Azure Container Apps

## Task: 004-deployment-azure-container-apps

| Property | Value |
|---|---|
| **Application** | ReadingTimeDemo |
| **Stack** | ASP.NET Core 10.0 MVC |
| **Target** | Azure Container Apps |
| **Region** | eastus |
| **Subscription** | `5b97b8de-e4f7-4787-a860-bcdc1130e599` (GitHub - Prod - DevRel - Hubathon) |
| **Resource Group** | `rg-readingtimedemo` |
| **IaC Tool** | Bicep |
| **Deploy Tool** | Azure CLI |

---

## Artifacts Generated

| File | Purpose |
|---|---|
| `infra/main.bicep` | Main Bicep orchestrator — provisions all 9 Azure resources |
| `infra/main.parameters.json` | Deployment parameters (environmentName, location) |
| `infra/modules/identity.bicep` | User-Assigned Managed Identity |
| `infra/modules/registry.bicep` | Azure Container Registry + AcrPull role assignment |
| `infra/modules/loganalytics.bicep` | Log Analytics Workspace |
| `infra/modules/appinsights.bicep` | Application Insights |
| `infra/modules/keyvault.bicep` | Key Vault + Secrets Officer role + App Insights secret |
| `infra/modules/appconfig.bicep` | App Configuration + Data Reader role |
| `infra/modules/storage.bicep` | Storage Account + Blob Contributor role + static-assets container |
| `infra/modules/containerappenv.bicep` | Container Apps Environment (Log Analytics connected) |
| `infra/modules/containerapp.bicep` | Container App (User-assigned MI, CORS, health check, registry) |
| `infra/deploy.sh` | Full end-to-end Linux/macOS deploy (provision + build + deploy) |
| `infra/deploy.ps1` | Full end-to-end Windows deploy (provision + build + deploy) |
| `infra/README.md` | Infrastructure documentation |
| `infra/compliance.md` | Rules compliance report (24/24 rules applied) |
| `infra/infra-config.md` | Resource summary (to be updated with actual values post-provision) |
| `src/ReadingTimeDemo/Dockerfile` | Updated to .NET 10, non-root user, HEALTHCHECK, port 8080 |
| `src/ReadingTimeDemo/.dockerignore` | Comprehensive build context exclusions |
| `deploy-scripts/deploy-app.sh` | Standalone image build + Container App update script |

---

## Azure Resources Provisioned

| Resource | Name Pattern | Purpose |
|---|---|---|
| User-Assigned Managed Identity | `azmi{token}` | All service-to-service auth via Managed Identity |
| Azure Container Registry | `azcr{token}` | Docker image storage (AcrPull via MI) |
| Log Analytics Workspace | `azlaw{token}` | Container App logs |
| Application Insights | `azai{token}` | Telemetry |
| Key Vault | `azkv{token}` | App Insights connection string secret |
| App Configuration | `azac{token}` | Externalized settings (Data Reader via MI) |
| Storage Account | `azst{token}` | Static assets blob container (Blob Contributor via MI) |
| Container Apps Environment | `azce{token}` | Hosting environment |
| Azure Container App | `azca{token}` | Application runtime |

---

## Security Design

- All Azure service connections use **User-Assigned Managed Identity** (no passwords or connection strings)
- Container runs as **non-root user** (UID 1001)
- Storage: local auth disabled, anonymous blob access disabled
- Key Vault: RBAC auth, public network access allowed
- ACR: admin user disabled, AcrPull role assigned to MI

---

## How to Deploy

### Prerequisites
- Azure CLI 2.60+ (`az --version`)
- Subscription-level **Contributor** role required to create resource group and resources
- Current account (`brntbeer@githubazure.com`) needs elevated permissions

### Step 1 — Provision + Deploy (full automated)
```bash
chmod +x infra/deploy.sh
./infra/deploy.sh rg-readingtimedemo eastus prod
```

### Step 2 — App-only redeploy (after initial provision)
```bash
# Get resource names from az outputs or infra-config.md
./deploy-scripts/deploy-app.sh rg-readingtimedemo <ACR_NAME> <CONTAINER_APP_NAME>
```

---

## Status

| Step | Status |
|---|---|
| Dockerfile updated (.NET 10, non-root, HEALTHCHECK) | ✅ Complete |
| Bicep IaC files generated (9 modules, clean `az bicep build`) | ✅ Complete |
| Deploy scripts created (deploy.sh, deploy.ps1, deploy-app.sh) | ✅ Complete |
| Azure infrastructure provisioned | ⚠️ Requires Contributor permissions on subscription |
| Docker image built & pushed to ACR | ⚠️ Pending provisioning |
| Container App updated with application image | ⚠️ Pending provisioning |

# Deployment Progress — 004-deployment-azure-container-apps

## Status Overview

| Step | Description | Status |
|------|-------------|--------|
| 1 | Containerization | ✅ Complete |
| 2 | Env Setup for AzCLI | ✅ Complete |
| 3 | Provisioning (Bicep) | ⚠️ Blocked — needs Contributor role |
| 4 | Check Azure Resources | 🔲 Pending |
| 5 | Deployment | 🔲 Pending |
| 6 | Summarize Result | ✅ Complete (summary generated) |

---

## Step-by-Step Log

### Step 1 — Containerization ✅
- [x] Dockerfile found at `src/ReadingTimeDemo/Dockerfile`
- [x] Dockerfile updated: ASP.NET Core 2.0 → .NET 10 (`mcr.microsoft.com/dotnet/sdk:10.0` / `mcr.microsoft.com/dotnet/aspnet:10.0`)
- [x] Port changed from 80 → 8080 (ACA best practice)
- [x] Non-root user added (UID 1001, `appuser`)
- [x] HEALTHCHECK instruction added
- [x] `.dockerignore` enhanced (bin, obj, git, secrets excluded)

### Step 2 — Env Setup ✅
- [x] Azure CLI 2.87.0 installed
- [x] Logged in as `brntbeer@githubazure.com`
- [x] Subscription set: `5b97b8de-e4f7-4787-a860-bcdc1130e599` (GitHub - Prod - DevRel - Hubathon)
- [x] Service connector extension: already up to date (v3.3.6)

### Step 3 — Provisioning ⚠️ Blocked
- [x] `appmod-get-available-region` called — `eastus` confirmed available for all resource types
- [x] `appmod-get-iac-rules` called — 24 rules identified and applied
- [x] `appmod-check-quota` called — eastus quota sufficient
- [x] Bicep IaC files generated (9 modules + main.bicep, clean `az bicep build`)
- [x] `deploy.sh` and `deploy.ps1` created
- ❌ `az group create` failed — `AuthorizationFailed`: `brntbeer@githubazure.com` lacks Contributor role
  - Checked all subscriptions — no accessible resource groups found
  - **Action required**: Grant Contributor (or Resource Group Contributor) role on subscription `5b97b8de-e4f7-4787-a860-bcdc1130e599` to `brntbeer@githubazure.com`, then run `./infra/deploy.sh`

### Step 4 — Resource Verification
- 🔲 Pending (depends on Step 3)

### Step 5 — Deployment
- 🔲 Pending (depends on Step 3)
- [x] `deploy-scripts/deploy-app.sh` created and ready

### Step 6 — Summary ✅
- [x] `deployment-summary.md` generated


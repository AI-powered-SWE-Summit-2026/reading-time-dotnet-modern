# deploy.ps1 — Provision and deploy ReadingTimeDemo to Azure Container Apps
# Usage: .\infra\deploy.ps1 [-ResourceGroup <name>] [-Location <region>] [-EnvironmentName <env>]
param(
    [string]$ResourceGroup = "rg-readingtimedemo",
    [string]$Location = "eastus",
    [string]$EnvironmentName = "prod",
    [string]$ImageTag = "latest"
)

$SubscriptionId = "5b97b8de-e4f7-4787-a860-bcdc1130e599"
$ScriptDir = $PSScriptRoot

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ReadingTimeDemo — Azure Container Apps Deployment" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Resource Group : $ResourceGroup"
Write-Host "  Location       : $Location"
Write-Host "  Environment    : $EnvironmentName"
Write-Host "  Subscription   : $SubscriptionId"
Write-Host "============================================================" -ForegroundColor Cyan

# ── Step 1: Set subscription ─────────────────────────────────────────────────
Write-Host "`n[1/6] Setting Azure subscription..." -ForegroundColor Yellow
az account set --subscription $SubscriptionId
if ($LASTEXITCODE -ne 0) { throw "Failed to set subscription." }
az account show --query "{Name:name, ID:id}" -o table

# ── Step 2: Create resource group ────────────────────────────────────────────
Write-Host "`n[2/6] Creating/verifying resource group '$ResourceGroup'..." -ForegroundColor Yellow
az group create `
  --name $ResourceGroup `
  --location $Location `
  --tags project=ReadingTimeDemo environment=$EnvironmentName `
  --output table
if ($LASTEXITCODE -ne 0) { throw "Failed to create resource group." }

# ── Step 3: Validate Bicep template ──────────────────────────────────────────
Write-Host "`n[3/6] Validating Bicep template..." -ForegroundColor Yellow
az deployment group validate `
  --resource-group $ResourceGroup `
  --template-file "$ScriptDir\main.bicep" `
  --parameters "$ScriptDir\main.parameters.json" `
  --parameters environmentName=$EnvironmentName location=$Location `
  --output table
if ($LASTEXITCODE -ne 0) { throw "Bicep template validation failed." }

# ── Step 4: Provision infrastructure ─────────────────────────────────────────
Write-Host "`n[4/6] Provisioning Azure infrastructure (5-10 minutes)..." -ForegroundColor Yellow
$Timestamp = Get-Date -Format "yyyyMMddHHmmss"
$DeploymentOutputJson = az deployment group create `
  --resource-group $ResourceGroup `
  --template-file "$ScriptDir\main.bicep" `
  --parameters "$ScriptDir\main.parameters.json" `
  --parameters environmentName=$EnvironmentName location=$Location `
  --name "readingtimedemo-$Timestamp" `
  --output json
if ($LASTEXITCODE -ne 0) { throw "Infrastructure provisioning failed." }

$DeploymentOutput = $DeploymentOutputJson | ConvertFrom-Json

$AcrName           = $DeploymentOutput.properties.outputs.containerRegistryName.value
$AcrLoginServer    = $DeploymentOutput.properties.outputs.containerRegistryLoginServer.value
$ContainerAppName  = $DeploymentOutput.properties.outputs.containerAppName.value
$ContainerAppFqdn  = $DeploymentOutput.properties.outputs.containerAppFqdn.value
$MiClientId        = $DeploymentOutput.properties.outputs.managedIdentityClientId.value

Write-Host "`nProvisioned resources:"
Write-Host "  ACR Name         : $AcrName"
Write-Host "  ACR Login Server : $AcrLoginServer"
Write-Host "  Container App    : $ContainerAppName"
Write-Host "  App FQDN         : $ContainerAppFqdn"

# ── Step 5: Build & push Docker image ────────────────────────────────────────
Write-Host "`n[5/6] Building and pushing Docker image to ACR..." -ForegroundColor Yellow
$RepoRoot = (Get-Item "$ScriptDir\..").FullName
$ImageName = "readingtimedemo"
$FullImage = "${AcrLoginServer}/${ImageName}:${ImageTag}"

az acr build `
  --registry $AcrName `
  --image "${ImageName}:${ImageTag}" `
  --file "$RepoRoot\src\ReadingTimeDemo\Dockerfile" `
  "$RepoRoot\src\ReadingTimeDemo" `
  --platform linux/amd64
if ($LASTEXITCODE -ne 0) { throw "ACR build failed." }
Write-Host "Image pushed: $FullImage"

# ── Step 6: Update Container App with new image ───────────────────────────────
Write-Host "`n[6/6] Updating Container App with application image..." -ForegroundColor Yellow
az containerapp update `
  --name $ContainerAppName `
  --resource-group $ResourceGroup `
  --image $FullImage `
  --output table
if ($LASTEXITCODE -ne 0) { throw "Container App update failed." }

Write-Host "`n============================================================" -ForegroundColor Green
Write-Host "  Deployment Complete!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  Application URL : https://$ContainerAppFqdn"
Write-Host "  Container App   : $ContainerAppName"
Write-Host "  Resource Group  : $ResourceGroup"
Write-Host "============================================================" -ForegroundColor Green

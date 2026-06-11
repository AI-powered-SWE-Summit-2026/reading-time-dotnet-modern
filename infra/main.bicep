targetScope = 'resourceGroup'

@description('Environment name used for resource naming and token generation')
param environmentName string = 'prod'

@description('Azure region for resource deployment')
param location string = 'eastus'

@description('Name of the static assets blob container')
param staticAssetsContainerName string = 'static-assets'

// Resource token scoped to subscription + resource group + location + environment
var resourceToken = uniqueString(subscription().id, resourceGroup().id, location, environmentName)

var tags = {
  environment: environmentName
  project: 'ReadingTimeDemo'
  managedBy: 'bicep'
}

// ── User-Assigned Managed Identity ──────────────────────────────────────────
module identity 'modules/identity.bicep' = {
  name: 'identity'
  params: {
    location: location
    resourceToken: resourceToken
    tags: tags
  }
}

// ── Container Registry ───────────────────────────────────────────────────────
module registry 'modules/registry.bicep' = {
  name: 'registry'
  params: {
    location: location
    resourceToken: resourceToken
    managedIdentityPrincipalId: identity.outputs.identityPrincipalId
    tags: tags
  }
}

// ── Log Analytics Workspace ──────────────────────────────────────────────────
module logAnalytics 'modules/loganalytics.bicep' = {
  name: 'loganalytics'
  params: {
    location: location
    resourceToken: resourceToken
    tags: tags
  }
}

// ── Application Insights ─────────────────────────────────────────────────────
module appInsights 'modules/appinsights.bicep' = {
  name: 'appinsights'
  params: {
    location: location
    resourceToken: resourceToken
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
    tags: tags
  }
}

// ── Key Vault ────────────────────────────────────────────────────────────────
module keyVault 'modules/keyvault.bicep' = {
  name: 'keyvault'
  params: {
    location: location
    resourceToken: resourceToken
    managedIdentityPrincipalId: identity.outputs.identityPrincipalId
    appInsightsConnectionString: appInsights.outputs.connectionString
    tags: tags
  }
}

// ── App Configuration ────────────────────────────────────────────────────────
module appConfig 'modules/appconfig.bicep' = {
  name: 'appconfig'
  params: {
    location: location
    resourceToken: resourceToken
    managedIdentityPrincipalId: identity.outputs.identityPrincipalId
    tags: tags
  }
}

// ── Storage Account (Blob for static assets) ─────────────────────────────────
module storage 'modules/storage.bicep' = {
  name: 'storage'
  params: {
    location: location
    resourceToken: resourceToken
    managedIdentityPrincipalId: identity.outputs.identityPrincipalId
    staticAssetsContainerName: staticAssetsContainerName
    tags: tags
  }
}

// ── Container Apps Environment ────────────────────────────────────────────────
module containerAppEnv 'modules/containerappenv.bicep' = {
  name: 'containerappenv'
  params: {
    location: location
    resourceToken: resourceToken
    logAnalyticsCustomerId: logAnalytics.outputs.customerId
    logAnalyticsPrimarySharedKey: logAnalytics.outputs.primarySharedKey
    tags: tags
  }
}

// ── Container App ─────────────────────────────────────────────────────────────
module containerApp 'modules/containerapp.bicep' = {
  name: 'containerapp'
  dependsOn: [
    keyVault
  ]
  params: {
    location: location
    resourceToken: resourceToken
    containerAppEnvId: containerAppEnv.outputs.envId
    managedIdentityId: identity.outputs.identityId
    managedIdentityClientId: identity.outputs.identityClientId
    registryLoginServer: registry.outputs.loginServer
    appInsightsConnectionString: appInsights.outputs.connectionString
    appConfigEndpoint: appConfig.outputs.endpoint
    storageAccountUri: storage.outputs.storageAccountUri
    tags: tags
  }
}

// ── Outputs ───────────────────────────────────────────────────────────────────
output resourceGroupName string = resourceGroup().name
output location string = location
output managedIdentityName string = identity.outputs.identityName
output managedIdentityClientId string = identity.outputs.identityClientId
output containerRegistryName string = registry.outputs.registryName
output containerRegistryLoginServer string = registry.outputs.loginServer
output logAnalyticsWorkspaceName string = logAnalytics.outputs.workspaceName
output appInsightsName string = appInsights.outputs.appInsightsName
output keyVaultName string = keyVault.outputs.keyVaultName
output keyVaultUri string = keyVault.outputs.keyVaultUri
output appConfigName string = appConfig.outputs.appConfigName
output appConfigEndpoint string = appConfig.outputs.endpoint
output storageAccountName string = storage.outputs.storageAccountName
output storageAccountUri string = storage.outputs.storageAccountUri
output containerAppEnvName string = containerAppEnv.outputs.envName
output containerAppName string = containerApp.outputs.containerAppName
output containerAppFqdn string = containerApp.outputs.containerAppFqdn

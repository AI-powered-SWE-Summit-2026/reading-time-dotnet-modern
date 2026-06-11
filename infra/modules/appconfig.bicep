param location string
param resourceToken string
param managedIdentityPrincipalId string
param tags object = {}

resource appConfiguration 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  #disable-next-line BCP334
  name: 'azac${resourceToken}'
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    disableLocalAuth: false
  }
  tags: tags
}

// App Configuration Data Reader role for managed identity
var appConfigDataReaderRoleId = '516239f1-63e1-4d78-a4de-a74fb236a071'
resource appConfigReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(appConfiguration.id, managedIdentityPrincipalId, appConfigDataReaderRoleId)
  scope: appConfiguration
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', appConfigDataReaderRoleId)
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output appConfigId string = appConfiguration.id
output appConfigName string = appConfiguration.name
output endpoint string = appConfiguration.properties.endpoint

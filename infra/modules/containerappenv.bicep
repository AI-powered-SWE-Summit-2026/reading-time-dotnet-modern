param location string
param resourceToken string
param logAnalyticsCustomerId string

@secure()
param logAnalyticsPrimarySharedKey string
param tags object = {}

resource containerAppEnv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: 'azce${resourceToken}'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsCustomerId
        sharedKey: logAnalyticsPrimarySharedKey
      }
    }
  }
  tags: tags
}

output envId string = containerAppEnv.id
output envName string = containerAppEnv.name

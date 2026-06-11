param location string
param resourceToken string
param containerAppEnvId string
param managedIdentityId string
param managedIdentityClientId string
param registryLoginServer string
@secure()
param appInsightsConnectionString string
param appConfigEndpoint string
param storageAccountUri string
param tags object = {}

// Container App — uses User-Assigned Managed Identity (NOT system-assigned) per rules.
// Initial image is the ACA hello-world placeholder per rules; updated post-provision via deploy script.
resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'azca${resourceToken}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    environmentId: containerAppEnvId
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
        transport: 'http'
        // Enable CORS (per rules)
        corsPolicy: {
          allowedOrigins: ['*']
          allowedMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS']
          allowedHeaders: ['*']
          allowCredentials: false
        }
      }
      // Registry connection using user-assigned managed identity (per rules)
      registries: [
        {
          server: registryLoginServer
          identity: managedIdentityId
        }
      ]
      // Direct secret for initial deploy (Key Vault reference added post-deploy per guidance)
      secrets: [
        {
          name: 'appinsights-connection-string'
          value: appInsightsConnectionString
        }
      ]
    }
    template: {
      // MANDATORY: base container image as required by rules
      containers: [
        {
          name: 'readingtimedemo'
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          env: [
            {
              name: 'ASPNETCORE_ENVIRONMENT'
              value: 'Production'
            }
            {
              name: 'ASPNETCORE_URLS'
              value: 'http://+:8080'
            }
            {
              name: 'AZURE_APP_CONFIGURATION_ENDPOINT'
              value: appConfigEndpoint
            }
            {
              name: 'AZURE_CLIENT_ID'
              value: managedIdentityClientId
            }
            {
              name: 'Storage__ServiceUri'
              value: storageAccountUri
            }
            {
              name: 'Storage__StaticAssetsContainerName'
              value: 'static-assets'
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              secretRef: 'appinsights-connection-string'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
  tags: tags
}

output containerAppId string = containerApp.id
output containerAppName string = containerApp.name
output containerAppFqdn string = containerApp.properties.configuration.ingress.fqdn

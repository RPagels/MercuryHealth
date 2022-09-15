param keyvaultName string
param kvValue_configStoreConnectionName string
param kvValue_ConnectionStringName string
param webappName string
param functionAppName string
param kvValue_AzureWebJobsStorageName string
param kvValue_WebsiteContentAzureFileConnectionStringName string
param appInsightsInstrumentationKey string
param appInsightsConnectionString string
param Deployed_Environment string
param ApimSubscriptionKey string
param ApimWebServiceURL string
//param appServiceName string

//param location string = resourceGroup().location
//param vaultName string

@secure()
param kvValue_configStoreConnectionValue string

@secure()
param kvValue_ConnectionStringValue string

@secure()
param appServiceprincipalId string

@secure()
param funcAppServiceprincipalId string

@secure()
param configStoreprincipalId string

@secure()
param kvValue_AzureWebJobsStorageValue string

param tenant string = subscription().tenantId

@secure()
param AzObjectIdPagels string

// Define KeyVault accessPolicies
param accessPolicies array = [
  {
    tenantId: tenant
    objectId: appServiceprincipalId
    permissions: {
      keys: [
        'get'
        'list'
      ]
      secrets: [
        'get'
        'list'
      ]
    }
  }
  {
    tenantId: tenant
    objectId: funcAppServiceprincipalId
    permissions: {
      keys: [
        'get'
        'list'
      ]
      secrets: [
        'get'
        'list'
      ]
    }
  }
  {
    tenantId: tenant
    objectId: configStoreprincipalId
    permissions: {
      keys: [
        'get'
        'list'
      ]
      secrets: [
        'get'
        'list'
      ]
    }
  }
  {
    tenantId: tenant
    objectId: AzObjectIdPagels
    permissions: {
      keys: [
        'get'
        'list'
      ]
      secrets: [
        'get'
        'list'
        'set'
        'delete'
      ]
    }
  }
]

// Reference Existing resource
resource existing_keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyvaultName
}

// Create KeyVault accessPolicies
resource keyvaultaccessmod 'Microsoft.KeyVault/vaults/accessPolicies@2021-11-01-preview' = {
  name: 'add'
  parent: existing_keyvault
  properties: {
    accessPolicies: accessPolicies
  }
}

// Create KeyVault Secrets
resource secret1 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: kvValue_configStoreConnectionName
  parent: existing_keyvault
  properties: {
    value: kvValue_configStoreConnectionValue
  }
}

// create secret for Web App
resource secret2 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: kvValue_ConnectionStringName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: kvValue_ConnectionStringValue
  }
}
//create secret for Func App
resource secret3 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: kvValue_AzureWebJobsStorageName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: kvValue_AzureWebJobsStorageValue
  }
}
// create secret for Func App
resource secret4 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: kvValue_WebsiteContentAzureFileConnectionStringName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: kvValue_AzureWebJobsStorageValue
  }
}
// Reference Existing resource
resource existing_appService 'Microsoft.Web/sites@2021-03-01' existing = {
  name: webappName
}

// Create Web sites/config 'appsettings' - Web App
resource webSiteAppSettingsStrings 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'appsettings'
  parent: existing_appService
  properties: {
    'ConnectionStrings:MercuryHealthWebContext': '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${kvValue_ConnectionStringName})'
    'ConnectionStrings:AppConfig': '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${kvValue_configStoreConnectionName})'
    DeployedEnvironment: Deployed_Environment
    WEBSITE_RUN_FROM_PACKAGE: '1'
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsightsInstrumentationKey
    APPINSIGHTS_PROFILERFEATURE_VERSION: '1.0.0'
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION: '1.0.0'
    APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectionString
    WebAppUrl: 'https://${existing_appService.name}.azurewebsites.net/'
    ASPNETCORE_ENVIRONMENT: 'Development'
  }
  dependsOn: [
    secret1
    secret2
  ]
}

// Reference Existing resource
resource existing_funcAppService 'Microsoft.Web/sites@2021-03-01' existing = {
  name: functionAppName
}
// Create Web sites/config 'appsettings' - Function App
resource funcAppSettingsStrings 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: existing_funcAppService
  properties: {
    AzureWebJobsStorage: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${kvValue_AzureWebJobsStorageName})'
    WebsiteContentAzureFileConnectionString: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${kvValue_WebsiteContentAzureFileConnectionStringName})'
    ApimSubscriptionKey: ApimSubscriptionKey
    ApimWebServiceURL: ApimWebServiceURL
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsightsInstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectionString
    FUNCTIONS_WORKER_RUNTIME: 'dotnet'
    FUNCTIONS_EXTENSION_VERSION: '~4'
  }
  dependsOn: [
    secret3
    secret4
  ]
}



param keyvaultName string
param secret_configStoreConnectionName string
param secret_ConnectionStringName string
param webappName string
param functionAppName string
param secret_AzureWebJobsStorageName string
param secret_WebsiteContentAzureFileConnectionStringName string
param appInsightsInstrumentationKey string
param appInsightsConnectionString string
param Deployed_Environment string
//param appServiceName string

//param location string = resourceGroup().location
//param vaultName string

@secure()
param secret_configStoreConnectionValue string

@secure()
param secret_ConnectionStringValue string

@secure()
param appServiceprincipalId string

@secure()
param funcAppServiceprincipalId string

@secure()
param secret_AzureWebJobsStorageValue string

param tenant string = subscription().tenantId

// Define KeyVault accessPolicies
param accessPolicies array = [
  {
    tenantId: tenant
    objectId: appServiceprincipalId
    permissions: {
      keys: [
        'Get'
        'List'
      ]
      secrets: [
        'Get'
        'List'
      ]
    }
  }
  {
    tenantId: tenant
    objectId: funcAppServiceprincipalId
    permissions: {
      keys: [
        'Get'
        'List'
      ]
      secrets: [
        'Get'
        'List'
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
  name: secret_configStoreConnectionName
  parent: existing_keyvault
  properties: {
    value: secret_configStoreConnectionValue
  }
}

// create secret for Web App
resource secret2 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: secret_ConnectionStringName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: secret_ConnectionStringValue
  }
}
//create secret for Func App
resource secret3 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: secret_AzureWebJobsStorageName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: secret_AzureWebJobsStorageValue
  }
}
// create secret for Func App
resource secret4 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: secret_WebsiteContentAzureFileConnectionStringName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: secret_AzureWebJobsStorageValue
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
    'ConnectionStrings:MercuryHealthWebContext': '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${secret_configStoreConnectionName})'
    'ConnectionStrings:AppConfig': '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${secret_ConnectionStringName})'
    'DeployedEnvironment': Deployed_Environment
    'WEBSITE_RUN_FROM_PACKAGE': '1'
    'APPINSIGHTS_INSTRUMENTATIONKEY': appInsightsInstrumentationKey
    'APPINSIGHTS_PROFILERFEATURE_VERSION': '1.0.0'
    'APPINSIGHTS_SNAPSHOTFEATURE_VERSION': '1.0.0'
    'APPLICATIONINSIGHTS_CONNECTION_STRING': appInsightsConnectionString
    'WebAppUrl': 'https://${existing_appService.name}.azurewebsites.net/'
    'ASPNETCORE_ENVIRONMENT': 'Development'
    // 'DebugOnly-sqlAdminLoginPassword=': sqlAdminLoginPassword
    // 'DebugOnly-sqlAdminLoginName=': sqlAdminLoginName
    'DebugOnly-secret_ConnectionStringValue=': secret_ConnectionStringValue
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
    'AzureWebJobsStorage': '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${secret_AzureWebJobsStorageName})'
    'WebsiteContentAzureFileConnectionString': '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${secret_WebsiteContentAzureFileConnectionStringName})'
    'DebugOnly-secret_ConnectionStringValue=': secret_AzureWebJobsStorageValue
  }
  dependsOn: [
    secret3
    secret4
  ]
}

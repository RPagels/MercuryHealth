param skuName string = 'B1'
//param skuCapacity int = 1
param location string = resourceGroup().location
param Deployed_Environment string
param sqlserverName string
param sqlserverfullyQualifiedDomainName string
param sqlDBName string

// Azure SQL Credentials
@secure()
param sqlAdminLoginPassword string
@secure()
param sqlAdminLoginName string

// @secure()
// param sqlAdminLoginPassword2 string

param webAppPlanName string
param webSiteName string
param resourceGroupName string
param appInsightsName string
param keyvaultName string
param secretName1 string
param secretName2 string
param appInsightsInstrumentationKey string
param appInsightsConnectionString string
param defaultTags object
//param configStoreConnection string

// Varabiles
// var standardPlanMaxAdditionalSlots = 2
// param environments array = [
//   'dev'
//   'qa'
// ]

// resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-15' = {
//   name: webAppPlanName // app serivce plan name
//   location: location // Azure Region
//   tags: defaultTags
//   properties: {}
//   sku: {
//     name: ((length(environments) <= standardPlanMaxAdditionalSlots) ? skuName : 'P1')
//   }
// }

resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: webAppPlanName // app serivce plan name
  location: location // Azure Region
  tags: defaultTags
  properties: {}
  sku: {
    name: skuName
  }
}

resource appService 'Microsoft.Web/sites@2021-01-15' = {
  name: webSiteName // Globally unique app serivce name
  location: location
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  tags: defaultTags
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      minTlsVersion: '1.2'
      healthCheckPath: '/healthy'
    }
  }
}

resource webSiteAppSettingsStrings 'Microsoft.Web/sites/config@2021-03-01' = {
  //name: '${webSiteName}/appsettings'
  name: 'appsettings'
  parent: appService
  properties: {
    'ConnectionStrings:MercuryHealthWebContext': '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${secretName2})'
    'ConnectionStrings:AppConfig': '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${secretName1})'
    'DeployedEnvironment': Deployed_Environment
    'WEBSITE_RUN_FROM_PACKAGE': '1'
    'APPINSIGHTS_INSTRUMENTATIONKEY': appInsightsInstrumentationKey
    'APPINSIGHTS_PROFILERFEATURE_VERSION': '1.0.0'
    'APPINSIGHTS_SNAPSHOTFEATURE_VERSION': '1.0.0'
    'APPLICATIONINSIGHTS_CONNECTION_STRING': appInsightsConnectionString
    'WebAppUrl': 'https://${appService.name}.azurewebsites.net/'
    'ASPNETCORE_ENVIRONMENT': 'Development'
    'DebugOnly-sqlAdminLoginPassword=': sqlAdminLoginPassword
    'DebugOnly-sqlAdminLoginName=': sqlAdminLoginName
    'DebugOnly-sqlConnectionString=': secretConnectionString
  }
}

// resource webAppPortalName_environments 'Microsoft.Web/sites/slots@2021-03-01' = [for item in environments: {
//   name: '${webSiteName}/${item}'
//   kind: 'app'
//   location: location
//   tags: {
//     displayName: 'WebAppSlots'
//   }
//   properties: {
//     serverFarmId: appServicePlan.id
//   }
// }]

// Location population tags
// https://docs.microsoft.com/en-us/azure/azure-monitor/app/monitor-web-app-availability

resource standardWebTestPageHome  'Microsoft.Insights/webtests@2020-10-05-preview' = {
  name: 'Page Home'
  location: location
  tags: {
    'hidden-link:${subscription().id}/resourceGroups/${resourceGroupName}/providers/microsoft.insights/components/${appInsightsName}': 'Resource'
   }
  kind: 'ping'
  properties: {
    SyntheticMonitorId: appInsightsName
    Name: 'Page Home'
    Description: null
    Enabled: true
    Frequency: 300
    Timeout: 120 
    Kind: 'standard'
    RetryEnabled: true
    Locations: [
      {
        Id: 'us-va-ash-azr'  // East US
      }
      {
        Id: 'us-fl-mia-edge' // Central US
      }
      {
        Id: 'us-ca-sjc-azr' // West US
      }
      {
        Id: 'emea-au-syd-edge' // Austrailia East
      }
      {
        Id: 'apac-jp-kaw-edge' // Japan East
      }
    ]
    Configuration: null
    Request: {
      RequestUrl: 'https://${appService.name}.azurewebsites.net/'
      Headers: null
      HttpVerb: 'GET'
      RequestBody: null
      ParseDependentRequests: false
      FollowRedirects: null
    }
    ValidationRules: {
      ExpectedHttpStatusCode: 200
      IgnoreHttpsStatusCode: false
      ContentValidation: null
      SSLCheck: true
      SSLCertRemainingLifetimeCheck: 7
    }
  }
}

resource standardWebTestPageNutritions  'Microsoft.Insights/webtests@2020-10-05-preview' = {
  name: 'Page Nutritions'
  location: location
  tags: {
    'hidden-link:${subscription().id}/resourceGroups/${resourceGroupName}/providers/microsoft.insights/components/${appInsightsName}': 'Resource'
  }
  kind: 'ping'
  properties: {
    SyntheticMonitorId: appInsightsName
    Name: 'Page Nutritions'
    Description: null
    Enabled: true
    Frequency: 300
    Timeout: 120 
    Kind: 'standard'
    RetryEnabled: true
    Locations: [
      {
        Id: 'us-va-ash-azr'  // East US
      }
      {
        Id: 'us-fl-mia-edge' // Central US
      }
      {
        Id: 'us-ca-sjc-azr' // West US
      }
      {
        Id: 'emea-au-syd-edge' // Austrailia East
      }
      {
        Id: 'apac-jp-kaw-edge' // Japan East
      }
    ]
    Configuration: null
    Request: {
      RequestUrl: 'https://${appService.name}.azurewebsites.net/Nutritions/'
      Headers: null
      HttpVerb: 'GET'
      RequestBody: null
      ParseDependentRequests: false
      FollowRedirects: null
    }
    ValidationRules: {
      ExpectedHttpStatusCode: 200
      IgnoreHttpsStatusCode: false
      ContentValidation: null
      SSLCheck: true
      SSLCertRemainingLifetimeCheck: 7
    }
  }
}

resource standardWebTestPageExercises  'Microsoft.Insights/webtests@2020-10-05-preview' = {
  name: 'Page Exercises'
  location: location
  tags: {
     'hidden-link:${subscription().id}/resourceGroups/${resourceGroupName}/providers/microsoft.insights/components/${appInsightsName}': 'Resource'
  }
  kind: 'ping'
  properties: {
    SyntheticMonitorId: appInsightsName
    Name: 'Page Exercises'
    Description: null
    Enabled: true
    Frequency: 300
    Timeout: 120 
    Kind: 'standard'
    RetryEnabled: true
    Locations: [
      {
        Id: 'us-va-ash-azr'  // East US
      }
      {
        Id: 'us-fl-mia-edge' // Central US
      }
      {
        Id: 'us-ca-sjc-azr' // West US
      }
      {
        Id: 'emea-au-syd-edge' // Austrailia East
      }
      {
        Id: 'apac-jp-kaw-edge' // Japan East
      }
    ]
    Configuration: null
    Request: {
      RequestUrl: 'https://${appService.name}.azurewebsites.net/Exercises/'
      Headers: null
      HttpVerb: 'GET'
      RequestBody: null
      ParseDependentRequests: false
      FollowRedirects: null
    }
    ValidationRules: {
      ExpectedHttpStatusCode: 200
      IgnoreHttpsStatusCode: false
      ContentValidation: null
      SSLCheck: true
      SSLCertRemainingLifetimeCheck: 7
    }
  }
}

// Reference Existing resource
// resource existingkeyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
//   name: keyvaultName
// }

// // create secret
// resource mySecret1 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
//   name: '${keyvaultName}/${secretName1}'
//   // parent: existingkeyvault
//   properties: {
//     contentType: 'text/plain'
//     value: configStoreConnection
//   }
// }

var secretConnectionString = 'Server=tcp:${sqlserverfullyQualifiedDomainName},1433;Initial Catalog=${sqlDBName};Persist Security Info=False;User Id=${sqlAdminLoginName}@${sqlserverName};Password=${sqlAdminLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

// create secret
// resource mySecret2 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
//   name: '${keyvaultName}/${secretName2}'
//   //parent: existingkeyvault
//   properties: {
//     contentType: 'text/plain'
//     //value: 'Server=tcp:${sqlserverfullyQualifiedDomainName},1433;Initial Catalog=${sqlDBName};Persist Security Info=False;User Id=${sqlAdminLoginName}@${sqlserverName};Password=${sqlAdminLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
//     //value: 'Server=tcp:${sqlserverfullyQualifiedDomainName},1433;Initial Catalog=${sqlDBName};Persist Security Info=False;User Id=${sqlAdminLoginName}@${sqlserverName};Password=${sqlAdminLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
//     value: secretConnectionString
//   }
// }

output out_appService string = appService.id
output out_webSiteName string = appService.properties.defaultHostName
output out_appServiceprincipalId string = appService.identity.principalId
output out_secretConnectionString string = secretConnectionString


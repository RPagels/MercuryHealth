// Deploy Azure infrastructure for app + data + monitoring

//targetScope = 'subscription'
// Region for all resources
param location string = resourceGroup().location
//param environment string = 'dev'
param createdBy string = 'Randy Pagels' // resourceGroup().managedBy
param costCenter string = '74f644d3e665'
param releaseAnnotationGuid string = newGuid()
//param guidValue string = newGuid()

// Data params
param Deployed_Environment string

// @secure()
// param sqlAdministratorLogin string

// @secure()
// param sqlAdministratorLoginPassword string

// Generate Azure SQL Credentials
var sqlAdminLoginName = 'AzureAdmin'
//var sqlAdminLoginPassword = 'Password.1.!!'
var sqlAdminLoginPassword = '${substring(base64(uniqueString(resourceGroup().id)), 0, 10)}.!&!.${uniqueString(resourceGroup().id)}'

// Variables for Recommended abbreviations for Azure resource types
// https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
var webAppPlanName = 'plan-${uniqueString(resourceGroup().id)}'
var webSiteName = 'app-${uniqueString(resourceGroup().id)}'
var sqlserverName = toLower('sql-${uniqueString(resourceGroup().id)}')
var sqlDBName = toLower('sqldb-${uniqueString(resourceGroup().id)}')
var configStoreName = 'appcs-${uniqueString(resourceGroup().id)}'
var appInsightsName = 'appi-${uniqueString(resourceGroup().id)}'
var appInsightsWorkspaceName = 'appw-${uniqueString(resourceGroup().id)}'
var appInsightsAlertName = 'ResponseTime-${uniqueString(resourceGroup().id)}'
var functionAppName = 'func-${uniqueString(resourceGroup().id)}'
var functionAppServiceName = 'funcplan-${uniqueString(resourceGroup().id)}'
var apiServiceName = 'apimv2-${uniqueString(resourceGroup().id)}'
var loadTestsName = 'loadtests-${uniqueString(resourceGroup().id)}'
var keyvaultName = 'kv-${uniqueString(resourceGroup().id)}'
var blobstorageName = 'stablob${uniqueString(resourceGroup().id)}'
var dashboardName = 'dashboard-${uniqueString(resourceGroup().id)}'

// Tags
var defaultTags = {
  'Env': Deployed_Environment
  'App': 'Mercury Health'
  'CostCenter': costCenter
  'CreatedBy': createdBy
}

// KeyVault Secret Names
param secretName1 string = 'ConnectionStringsAppConfig'
param secretName2 string = 'ConnectionStringsMercuryHealthWebContext'
param secretName3 string = 'AzureWebJobsStorage'
param secretName4 string = 'WebsiteContentAzureFileConnectionString'

////////////////////////////////////////
// BEGIN - Create Config Store
////////////////////////////////////////

@description('Specifies the content type of the key-value resources. For feature flag, the value should be application/vnd.microsoft.appconfig.ff+json;charset=utf-8. For Key Value reference, the value should be application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8. Otherwise, it\'s optional.')
param contentType string = 'application/vnd.microsoft.appconfig.ff+json;charset=utf-8'

// Specifies the names of the key-value resources. 
param ConfigkeyValueNames array = [
  'App:Settings:FontSize'
  'App:Settings:FontColor'
  'App:Settings:BackgroundColor'
  'App:Settings:Sentinel'
]

// Specifies the values of the key-value resources. #000=Black, #FFF=White
param ConfigkeyKeyValues array = [
  '13'
  'black'
  'white'
  '1'
]

param FeatureFlagKey1 string = 'PrivacyBeta'
param FeatureFlagKey2 string = 'MetricsDashboard'
param FeatureFlagKey3 string = 'NutritionColor'
param FeatureFlagLabel1 string = 'Privacy Beta'
param FeatureFlagLabel2 string = 'Metrics Dashboard'
param FeatureFlagLabel3 string = 'Nutrition Color'

var FeatureFlagValue1 = {
  id: FeatureFlagKey1
  description: 'Description for Privacy Beta.'
  enabled: true
}
var FeatureFlagValue2 = {
  id: FeatureFlagKey2
  description: 'Description for Metrics Dashboard.'
  enabled: false
}
var FeatureFlagValue3 = {
  id: FeatureFlagKey3
  description: 'Description for Nutrition Color.'
  enabled: false
}

// Not able to loop through array creating FF
// param FeatureFlagkeyValueNames array = [
//   'PrivacyBeta'
//   'MetricsDashboard'
//   'NutritionColor'
// ]
// Not able to loop through array creating FF
// param FeatureFlagkeyValueLabels array = [
//   'Privacy Page'
//   'Metrics Dashboard'
//   'Capture Nutrition Color'
// ]
// Not able to loop through array creating FF
// param FeatureFlagkeyValueKeys array = [
//   'true'
//   'true'
//   'true'
// ]

// Create AppConfiguration configuration Store
// enableSoftDelete: false
resource config 'Microsoft.AppConfiguration/configurationStores@2021-10-01-preview' = {
  name: configStoreName
  location: location
  tags: defaultTags
  properties: {
    enablePurgeProtection: false
    //softDeleteRetentionInDays: 1
  }
  sku: {
    name: 'Standard'
  }
}

// Loop through array and create Config Key Values
resource configStoreName_keyValueNames 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = [for (item, i) in ConfigkeyValueNames: {
  name: '${config.name}/${item}' //'${config.name}/${item}'
  properties: {
    value: ConfigkeyKeyValues[i]
    //contentType: contentType
    tags: defaultTags
  }
}]

// Want to loop through array and create Feature Flags
// **Not** able to loop through array creating FF
// resource configStoreName_appconfig_featureflags 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = [for (item, i) in FeatureFlagkeyValueNames: {
//   parent: config
//   name: '.appconfig.featureflag~2F${FeatureFlagkeyValueNames[i]}$${FeatureFlagkeyValueLabels[i]}'
//   properties: {
//     value: string(FeatureFlagkeyValueKeys[i])
//     contentType: contentType
//   }
// }]

// Feature Flag 1
resource configStoreName_appconfig_featureflags_1 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  parent: config
  name: '.appconfig.featureflag~2F${FeatureFlagKey1}$${FeatureFlagLabel1}'
  properties: {
    value: string(FeatureFlagValue1)
    contentType: contentType
  }
}
// Feature Flag 2
resource configStoreName_appconfig_featureflags_2 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  parent: config
  name: '.appconfig.featureflag~2F${FeatureFlagKey2}$${FeatureFlagLabel2}'
  properties: {
    value: string(FeatureFlagValue2)
    contentType: contentType
  }
}
// Feature Flag 3
resource configStoreName_appconfig_featureflags_3 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  parent: config
  name: '.appconfig.featureflag~2F${FeatureFlagKey3}$${FeatureFlagLabel3}'
  properties: {
    value: string(FeatureFlagValue3)
    contentType: contentType
  }
}
////////////////////////////////////////
// END - Setup Config Store
////////////////////////////////////////

// AppConfiguration - Avoid outputs for secrets - Look up secrets dynamically
// https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/scenarios-secrets
// Note: This is why ConfigStore isn't it's own module...MUST be in the main
var configStoreConnectionString = listKeys(config.id, config.apiVersion).value[0].connectionString

////////////////////////////////////////
// START - Key Vault
////////////////////////////////////////

// Create Azure KeyVault
// module keyvaultmod './main-8-keyvault.bicep' = {
//   name: keyvaultName
//   params: {
//     location: location
//     vaultName: keyvaultName
//     appServiceprincipalId: webappmod.outputs.out_appServiceprincipalId
//     secretName1: secretName1
//     secretName2: secretName2
//     // secretName3: secretName3
//     // secretName4: secretName4
//     configStoreConnection: configStoreConnectionString
//     secretConnectionString: webappmod.outputs.out_secretConnectionString
//     //secretAzureWebJobsStorage: functionappmod.outputs.out_AzureWebJobsStorage
//     //funcAppServiceprincipalId: functionappmod.outputs.out_funcAppServiceprincipalId
//     }
//     dependsOn:  [
//      webappmod
//      //functionappmod
//    ]
//  }

//  param accessPolicies array = [
//   {
//     tenantId: subscription().tenantId
//     objectId: webappmod.outputs.out_appServiceprincipalId
//     permissions: {
//       keys: [
//         'Get'
//         'List'
//       ]
//       secrets: [
//         'Get'
//         'List'
//       ]
//     }
//   }

param networkAcls object = {
  ipRules: []
  virtualNetworkRules: []
}

resource keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: keyvaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableSoftDelete: false
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: false
    networkAcls: networkAcls
    accessPolicies:[
      {
      tenantId: subscription().tenantId
      objectId: webappmod.outputs.out_appServiceprincipalId
        permissions: {
          keys: [
            'list'
            'get'
          ]
          secrets: [
            'list'
            'get'
          ]
        }
      }
      // {
      //   tenantId: subscription().tenantId
      //   objectId: functionappmod.outputs.out_funcAppServiceprincipalId
      //     permissions: {
      //       keys: [
      //         'list'
      //         'get'
      //       ]
      //       secrets: [
      //         'list'
      //         'get'
      //       ]
      //     }
      // }
    ]
  }
  dependsOn:  [
    webappmod
    functionappmod
  ]
}

//  resource secret1 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
//    name: secretName1
//    parent: keyvaultmod
//    properties: {
//      contentType: 'text/plain'
//      value: configStoreConnectionString
//    }
//  }
//  resource secret2 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
//    name: secretName2
//    parent: keyvaultmod
//    properties: {
//      contentType: 'text/plain'
//      value: 'Server=tcp:${sqldbmod.outputs.sqlserverfullyQualifiedDomainName},1433;Initial Catalog=${sqlDBName};Persist Security Info=False;User Id=${sqlAdministratorLogin}@${sqlserverName};Password=${sqlAdministratorLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
//    }
//  }
 
// create secret for Web App
resource mySecret1 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: secretName1
  //name: '${keyvaultName}/${secretName1}'
  parent: keyvault
  properties: {
    contentType: 'text/plain'
    value: configStoreConnectionString
  }
  // dependsOn:  [
  //   keyvault
  // ]
}
// create secret for Web App
resource mySecret2 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: secretName2
  //name: '${keyvaultName}/${secretName2}'
  parent: keyvault
  properties: {
    contentType: 'text/plain'
    value: webappmod.outputs.out_secretConnectionString
  }
  // dependsOn:  [
  //   keyvault
  // ]
}
//create secret for Func App
// resource mySecret3 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
//   name: secretName3
//   //name: '${keyvaultName}/${secretName3}'
//   parent: keyvault
//   properties: {
//     contentType: 'text/plain'
//     value: functionappmod.outputs.out_AzureWebJobsStorage
//   }
//   // dependsOn:  [
//   //   keyvault
//   // ]
// }
// create secret for Func App
// resource mySecret4 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
//   name: secretName4
//   //name: '${keyvaultName}/${secretName4}'
//   parent: keyvault
//   properties: {
//     contentType: 'text/plain'
//     value: functionappmod.outputs.out_AzureWebJobsStorage
//   }
//   // dependsOn:  [
//   //   keyvault
//   // ]
// }

 ////////////////////////////////////////
 // END - Key Vault
 ////////////////////////////////////////
 
// AppConfiguration - Avoid outputs for secrets - Look up secrets dynamically
// https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/scenarios-secrets
// Note: This is why ConfigStore isn't it's own module...MUST be in the main
//var configStoreConnectionString = listKeys(config.id, config.apiVersion).value[0].connectionString

@minLength(1)
param publisherEmail string = 'rpagels@microsoft.com'
@minLength(1)
param publisherName string = 'Randy Pagels'
param sku string = 'Consumption'
param skuCount int = 0 // Must be Zero for Consumption

resource apiManagement 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: apiServiceName
  location: location
  tags: defaultTags
  sku: {
    name: sku
    capacity: skuCount
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource apiManagementSubscription 'Microsoft.ApiManagement/service/subscriptions@2021-08-01' = {
  parent: apiManagement
  name: 'Developers' //apiSubscriptionName
  properties: {
    scope: '/apis' // Subscription applies to all APIs
    displayName: 'Mercury Health - Developers' //apiSubscriptionName
  }
}

resource apiManagementProducts 'Microsoft.ApiManagement/service/products@2021-08-01' = {
  parent: apiManagement
  name: 'Development'
  properties: {
    approvalRequired: false
    state: 'notPublished'
    
    description: 'Product used for Mercury Health Development Teams'
    displayName: 'Mercury Health - Developers' //apiSubscriptionName
  }
}

resource appInsightsAPIManagement 'Microsoft.ApiManagement/service/loggers@2021-08-01' = {
  parent: apiManagement
  name: 'MercuryHealth-applicationinsights' //${apiServiceName}/${appInsightsName}' //MercuryHealth-applicationinsights'
  properties: {
    loggerType: 'applicationInsights'
    description: 'Mercury Health Application Insights instance.'
    resourceId: appinsightsmod.outputs.out_applicationInsightsID
    credentials: {
      instrumentationKey: appinsightsmod.outputs.out_appInsightsInstrumentationKey
    }
  }
  dependsOn:  [
    appinsightsmod
  ]
  
}

// API Management - Avoid outputs for secrets - Look up secrets dynamically
// Note: This is why API Management isn't it's own module...MUST be in the main
// resource apiManagement 'Microsoft.ApiManagement/service@2020-12-01' existing = {
//   name: apiServiceName
// }

var ApimSubscriptionKeyString = apiManagementSubscription.listSecrets().primaryKey

// Create Web App
module webappmod './main-2-webapp.bicep' = {
  name: 'webappdeploy'
  params: {
    webAppPlanName: webAppPlanName
    webSiteName: webSiteName
    resourceGroupName: resourceGroup().name
    Deployed_Environment: Deployed_Environment
    appInsightsName: appInsightsName
    location: location
    appInsightsInstrumentationKey: appinsightsmod.outputs.out_appInsightsInstrumentationKey
    appInsightsConnectionString: appinsightsmod.outputs.out_appInsightsConnectionString
    defaultTags: defaultTags
    keyvaultName: keyvaultName
    secretName1: secretName1
    secretName2: secretName2
    sqlAdminLoginName: sqlAdminLoginName
    sqlAdminLoginPassword: sqlAdminLoginPassword
    sqlDBName: sqlDBName
    sqlserverfullyQualifiedDomainName: sqldbmod.outputs.sqlserverfullyQualifiedDomainName
    sqlserverName: sqlserverName
  }

}

// Create SQL database
module sqldbmod './main-3-sqldatabase.bicep' = {
  name: 'sqldbdeploy'
  //scope: resourceGroup(location)
  params: {
    location: location
    sqlserverName: sqlserverName
    sqlDBName: sqlDBName
    sqlAdminLoginName: sqlAdminLoginName
    sqlAdminLoginPassword: sqlAdminLoginPassword
    defaultTags: defaultTags
  }
}

// Create Application Insights
module appinsightsmod './main-4-appinsights.bicep' = {
  name: 'appinsightsdeploy'
  params: {
    location: location
    appInsightsName: appInsightsName
    defaultTags: defaultTags
    appInsightsAlertName: appInsightsAlertName
    appInsightsWorkspaceName: appInsightsWorkspaceName
  }
}

// Create Function App
module functionappmod './main-6-funcapp.bicep' = {
  name: 'functionappdeploy'
  params: {
    location: location
    appInsightsInstrumentationKey: appinsightsmod.outputs.out_appInsightsInstrumentationKey
    functionAppServiceName: functionAppServiceName
    functionAppName: functionAppName
    defaultTags: defaultTags
    ApimSubscriptionKey: ApimSubscriptionKeyString
    ApimWebServiceURL: apiManagement.properties.gatewayUrl
    keyvaultName: keyvaultName
    secretName3: secretName3
    secretName4: secretName4
  }
}

// Create Azure Load Tests
module loadtestsmod './main-9-loadtests.bicep' = {
  name: loadTestsName
  params: {
    location: location
    loadTestsName: loadTestsName
    defaultTags: defaultTags
  }
}

module blogstoragemod './main-12-blobstorage.bicep' = {
  name: blobstorageName
  params: {
    location: location
     storageAccountName: blobstorageName
  }
}

// module portaldashboardmod './main-11-Dashboard.bicep' = {
//   name: dashboardName
//   params: {
//     location: location
//     appInsightsName: appInsightsName
//     dashboardName: dashboardName
//   }
// }

// Output Params used for IaC deployment in pipeline
output out_webSiteName string = webSiteName
output out_sqlserverName string = sqlserverName
output out_sqlDBName string = sqlDBName
output out_sqlserverFQName string = sqldbmod.outputs.sqlserverfullyQualifiedDomainName
output out_configStoreName string = configStoreName
output out_appInsightsName string = appInsightsName
output out_functionAppName string = functionAppName
output out_apiServiceName string = apiServiceName
output out_loadTestsName string = loadTestsName
output out_keyvaultName string = keyvaultName
output out_secretConnectionString string = webappmod.outputs.out_secretConnectionString
output out_appInsightsApplicationId string = appinsightsmod.outputs.out_appInsightsApplicationId
output out_appInsightsAPIApplicationId string = appinsightsmod.outputs.out_appInsightsAPIApplicationId
output out_releaseAnnotationGuidID string = releaseAnnotationGuid

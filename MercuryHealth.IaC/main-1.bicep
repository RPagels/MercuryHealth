// Deploy Azure infrastructure for app + data + monitoring

//targetScope = 'subscription'
// Region for all resources
param location string = resourceGroup().location
param environment string = 'dev'
param createdBy string = 'Randy Pagels' // resourceGroup().managedBy
param costCenter string = '74f644d3e665'
param releaseAnnotationGuid string = newGuid()

// Data params
@secure()
param sqlAdministratorLogin string

@secure()
param sqlAdministratorLoginPassword string

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
var apiServiceName = 'apim-${uniqueString(resourceGroup().id)}'
var loadTestsName = 'loadtests-${uniqueString(resourceGroup().id)}'
var keyvaultName = 'kv-${uniqueString(resourceGroup().id)}'
var blobstorageName = 'stablob${uniqueString(resourceGroup().id)}'
var dashboardName = 'dashboard-${uniqueString(resourceGroup().id)}'

// Tags
var defaultTags = {
  'Env': environment
  'App': 'Mercury Health'
  'CostCenter': costCenter
  'CreatedBy': createdBy
}

////////////////////////////////////////
// BEGIN - Create Config Store
////////////////////////////////////////

@description('Specifies the content type of the key-value resources. For feature flag, the value should be application/vnd.microsoft.appconfig.ff+json;charset=utf-8. For Key Value reference, the value should be application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8. Otherwise, it\'s optional.')
param contentType string = 'application/vnd.microsoft.appconfig.ff+json;charset=utf-8'

// Specifies the names of the key-value resources. 
param ConfigkeyValueNames array = [
  'MercuryHealth:Settings:FontSize'
  'MercuryHealth:Settings:Sentinel'
]

// Specifies the values of the key-value resources. It's optional
param ConfigkeyKeyValues array = [
  '14'
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
  sku: {
    name: 'Standard'
  }
}

// Loop through array and create Config Key Values
resource configStoreName_keyValueNames 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = [for (item, i) in ConfigkeyValueNames: {
  name: '${config.name}/${item}' //'${config.name}/${item}'
  properties: {
    value: ConfigkeyKeyValues[i]
    contentType: contentType
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

// API Management - Avoid outputs for secrets - Look up secrets dynamically
// Note: This is why API Management isn't it's own module...MUST be in the main
// resource apiManagement 'Microsoft.ApiManagement/service@2020-12-01' existing = {
//   name: apiServiceName
// }
//var ApimSubscriptionKeyString = listKeys(apiManagement.id, apiManagement.apiVersion).value[0].connectionString
//var ApimSubscriptionKeyString = 'tesing'
//var ApimSubscriptionKeyString = listKeys(apiManagement.id, apiManagement.apiVersion).primaryConnectionString
//var ApimSubscriptionKeyString = apiManagement.listKeys().keys[0].value

// This worked!
//var ApimSubscriptionKeyString = 'not working'

// Test 2
//var ApimSubscriptionKeyString = apiManagement.listKeys().keys[0].value

// Test 3
//var ApimSubscriptionKeyString = listKeys(apiManagement.id, apiManagement.apiVersion).value[0].value

// Test 4
//var ApimSubscriptionKeyString = apiManagement.listSecrets().keys[0].value

// Test 5
//var ApimSubscriptionKeyString = apiManagement.properties.gatewayUrl

// Test 6
//var ApimSubscriptionKeyString = listSecrets(apiManagement.id, apiManagement.apiVersion).value[0].value

// Test 7
var ApimSubscriptionKeyString = 'enterPrimaryKeyHere'


// Create Web App
module webappmod './main-2-webapp.bicep' = {
  name: 'webappdeploy'
  params: {
    webAppPlanName: webAppPlanName
    webSiteName: webSiteName
    resourceGroupName: resourceGroup().name
    appInsightsName: appInsightsName
    location: location
    configStoreConnection: configStoreConnectionString
    ApimSubscriptionKeyString: ApimSubscriptionKeyString
    sqlserverName: sqlserverName
    sqlserverfullyQualifiedDomainName: sqldbmod.outputs.sqlserverfullyQualifiedDomainName
    sqlDBName: sqlDBName
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    appInsightsInstrumentationKey: appinsightsmod.outputs.out_appInsightsInstrumentationKey
    appInsightsConnectionString: appinsightsmod.outputs.out_appInsightsConnectionString
    defaultTags: defaultTags
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
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
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

// Create Azure KeyVault
module keyvault './main-8-keyvault.bicep' = {
 name: keyvaultName
 params: {
   location: location
   vaultName: keyvaultName
   sqlserverName: sqlserverName
   sqlDBName: sqlDBName
   sqlAdministratorLogin: sqlAdministratorLogin
   sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
   configStoreConnection: configStoreConnectionString
   appInsightsInstrumentationKey: appinsightsmod.outputs.out_appInsightsInstrumentationKey
   }
}

// // Create APIM.  NOTE: MUST MOVE THIS. APIM + Azure KeyVault, needs to be in it's own RG + Pipeline
// module apiservicesmod './main-7-apimanagement.bicep' = {
//   name: apiServiceName
//   params: {
//     location: location
//     apiServiceName: apiServiceName
//     defaultTags: defaultTags
//   }
// }

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

output out_webSiteName string = webSiteName
output out_webSiteNameURL string = webappmod.outputs.out_webSiteName
output out_sqlserverName string = sqlserverName
output out_sqlDBName string = sqlDBName
output out_sqlserverFQName string = sqldbmod.outputs.sqlserverfullyQualifiedDomainName
//output out_sqlConnectionString string = webappmod.outputs.out_sqlConnectionString
output out_configStoreName string = configStoreName
output out_appInsightsName string = appInsightsName
output out_functionAppName string = functionAppName
output out_apiServiceName string = apiServiceName
output out_loadTestsName string = loadTestsName
output out_keyvaultName string = keyvaultName
output out_appInsightsApplicationId string = appinsightsmod.outputs.out_appInsightsApplicationId
output out_appInsightsAPIApplicationId string = appinsightsmod.outputs.out_appInsightsAPIApplicationId
output out_releaseAnnotationGuidID string = releaseAnnotationGuid

//test only
//output out_apiManagementKey string = apiManagement.properties.gatewayUrl

// Deploy Azure infrastructure for app + data + monitoring

//targetScope = 'subscription'
// Region for all resources
param location string = resourceGroup().location
param environment string = 'dev'
param createdBy string = resourceGroup().managedBy //'Randy Pagels'
param costCenter string = '74f644d3e665'
param releaseAnnotationGuid string = newGuid()

// Data params
@secure()
param sqlAdministratorLogin string

@secure()
param sqlAdministratorLoginPassword string

// Variables
// https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
var webAppPlanName = 'plan-${uniqueString(resourceGroup().id)}'
var webSiteName = 'app-${uniqueString(resourceGroup().id)}'
var sqlserverName = toLower('sql-${uniqueString(resourceGroup().id)}')
var sqlDBName = toLower('sqldb-${uniqueString(resourceGroup().id)}')
var configStoreName = 'appcs-${uniqueString(resourceGroup().id)}'
var appInsightsName = 'appi-${uniqueString(resourceGroup().id)}'
var appInsightsAlertName = 'ResponseTime-${uniqueString(resourceGroup().id)}'
var functionAppName = 'func-${uniqueString(resourceGroup().id)}'
var functionAppServiceName = 'funcplan-${uniqueString(resourceGroup().id)}'
var apiServiceName = 'apim-${uniqueString(resourceGroup().id)}'
var loadTestsName = 'loadtests-${uniqueString(resourceGroup().id)}'
var keyvaultName = 'kv-${uniqueString(resourceGroup().id)}'

// Tags
var defaultTags = {
  'Env': environment
  'App': 'Mercury Health'
  'CostCenter': costCenter
  'CreatedBy': createdBy
}

////////////////////////////////////////
// BEGIN - TESTING Config Store
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

param FeatureFlagkeyValueNames array = [
  'PrivacyBeta'
  'MetricsDashboard'
  'CognitiveServices'
  'CaptureNutritionColor'
]

param FeatureFlagkeyValueLabels array = [
  'Privacy Page'
  'Metrics Dashboard'
  'Cognitive Services'
  'Capture Nutrition Color'
]

param FeatureFlagkeyValueKeys array = [
  'true'
  'true'
  'true'
  'true'
]

// Create AppConfiguration configuration Store
resource config 'Microsoft.AppConfiguration/configurationStores@2021-03-01-preview' = {
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

// Loop through array and create Feature Flags
// resource configStoreName_appconfig_featureflags 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = [for (item, i) in FeatureFlagkeyValueNames: {
//   parent: config
//   name: '.appconfig.featureflag~2F${FeatureFlagkeyValueNames[i]}$${FeatureFlagkeyValueLabels[i]}'
//   properties: {
//     value: FeatureFlagkeyValueKeys[i]
//     contentType: contentType
//   }
// }]

// resource configStoreName_appconfig_featureflags 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = [for (item, i) in FeatureFlagkeyValueNames: {
//   parent: config
//   name: '.appconfig.featureflag~2F${FeatureFlagkeyValueNames[i]}$${FeatureFlagkeyValueLabels[i]}'
//   properties: {
//     value: FeatureFlagkeyValueKeys[i]
//     contentType: contentType
//   }
// }]

resource configStoreName_appconfig_featureflags 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = [for (item, i) in FeatureFlagkeyValueNames: {
  parent: config
  name: '.appconfig.featureflag~2F${FeatureFlagkeyValueNames[i]}$${FeatureFlagkeyValueLabels[i]}'
  properties: {
    value: FeatureFlagkeyValueNames[i]
    contentType: contentType
  }
}]

////////////////////////////////////////
// END - TESTING Config Store
////////////////////////////////////////

// Create Configuration Store Entries
// module configstoremod './main-5-configstore.bicep' = {
//   name: 'configstoredeploy'
//   params: {
//     configParent: config.id
//     location: location
//     defaultTags: defaultTags
//   }
// }

// Ask Kyle! Error during initial deployment.
// https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/existing-resource
//
// The Resource 'Microsoft.AppConfiguration/configurationStores/appcs-btocbms4557so' under resource group 'rg-MercuryHealth' was not found.
//
// Avoid outputs for secrets - Look up secrets dynamically
// resource config 'Microsoft.AppConfiguration/configurationStores@2021-03-01-preview' existing = {
//   name: configStoreName
// }
var configStoreConnectionString = listKeys(config.id, config.apiVersion).value[0].connectionString

// Lock Resoure Group
// resource dontDeleteLock 'Microsoft.Authorization/locks@2020-05-01' = {
//   name: 'DontDeleteMe'
//   properties: {
//     level: 'CanNotDelete'
//     notes: 'Prevent deletion of the resource group'
//   }
// }

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

// Create APIM.  NOTE: MUST MOVE THIS. APIM + Azure KeyVault, needs to be in it's own RG + Pipeline
module apiservicesmod './main-7-apimanagement.bicep' = {
name: apiServiceName
params: {
  location: location
  apiServiceName: apiServiceName
  defaultTags: defaultTags
}
}

output out_webSiteName string = webSiteName
output out_sqlserverName string = sqlserverName
output out_sqlDBName string = sqlDBName
output out_sqlserverFQName string = sqldbmod.outputs.sqlserverfullyQualifiedDomainName
//output out_sqlConnectionString string = 'Server=tcp:${sqlserverfullyQualifiedDomainName},1433;Initial Catalog=${sqlDBName};Persist Security Info=False;User Id=${sqlAdministratorLogin}@${sqlserverName};Password=${sqlAdministratorLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
output out_configStoreName string = configStoreName
output out_appInsightsName string = appInsightsName
output out_functionAppName string = functionAppName
output out_apiServiceName string = apiServiceName
output out_loadTestsName string = loadTestsName
output out_keyvaultName string = keyvaultName
output out_appInsightsApplicationId string = appinsightsmod.outputs.out_appInsightsApplicationId
output out_appInsightsAPIApplicationId string = appinsightsmod.outputs.out_appInsightsAPIApplicationId
output out_releaseAnnotationGuidID string = releaseAnnotationGuid

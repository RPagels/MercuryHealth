// Deploy Azure infrastructure for app + data + managed identity + monitoring

//targetScope = 'subscription'
// Region for all resources
param location string = resourceGroup().location
param environment string = 'dev'
param createdBy string = 'Randy Pagels'
param costCenter string = '74f644d3e665'

// Data params
//param serverName string
//param sqlDBName string = uniqueString('database-', resourceGroup().id)
param sqlAdministratorLogin string

@secure()
param sqlAdministratorLoginPassword string

// Variables
var webAppPlanName = 'appPlan-${uniqueString(resourceGroup().id)}'
var webSiteName = 'webSite-${uniqueString(resourceGroup().id)}'
//var webSiteURL = 'https://mercuryhealth2019v3-dev.azurewebsites.net/'
var sqlserverName = toLower('sqlServer-${uniqueString(resourceGroup().id)}')
var sqlDBName = 'MercuryHealthDB'
var configStoreName = 'appConfig-${uniqueString(resourceGroup().id)}'
var appInsightsName = 'appInsights-${uniqueString(resourceGroup().id)}'
var functionAppName = 'functionApp-${uniqueString(resourceGroup().id)}'
var functionAppServiceName = 'functionAppservice-${uniqueString(resourceGroup().id)}'
var apiServiceName = 'apiService-${uniqueString(resourceGroup().id)}'
//var keyvaultNamev2 = 'keyVault-${uniqueString(resourceGroup().id)}'

// Tags
var defaultTags = {
  'environment': environment
  'application': webSiteName
  'costcenter': costCenter
  'CreatedBy': createdBy
}

//resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
//  name: 'devopslab-demo'
//  location: 'eastus'
//}

resource config 'Microsoft.AppConfiguration/configurationStores@2021-03-01-preview' existing = {
  name: configStoreName
}
var configStoreConnectionString = '${listKeys(config.id, config.apiVersion).keys[0].value}'

// Create Web App
module webappmod './main-2-webapp.bicep' = {
  name: 'webappdeploy'
  params: {
    webAppPlanName: webAppPlanName
    webSiteName: webSiteName
     location: location
     sqlserverName: sqlserverName
     sqlserverfullyQualifiedDomainName: sqldbmod.outputs.sqlserverfullyQualifiedDomainName
     sqlDBName: sqlDBName
     sqlAdministratorLogin: sqlAdministratorLogin
     sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
     //configStoreEndpoint: configstoremod.outputs.configStoreEndpoint
     configStoreConnectionString: configStoreConnectionString //configstoremod.outputs.configStoreConnectionString
     appInsightsInstrumentationKey: appinsightsmod.outputs.appInsightsInstrumentationKey
     appInsightsConnectionString: appinsightsmod.outputs.appInsightsConnectionString
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

// Create Configuration Store
module configstoremod './main-5-configstore.bicep' = {
  name: 'configstoredeploy'
  params: {
    configStoreName: configStoreName
    location: location
    defaultTags: defaultTags
  }
}

// Create Application Insights
module appinsightsmod './main-4-appinsights.bicep' = {
  name: 'appinsightsdeploy'
  params: {
    location: location
    //webSiteName: webSiteName
    appInsightsName: appInsightsName
    //testEndpoint: webSiteURL
    defaultTags: defaultTags
  }
}

// Create Function App
module functionappmod './main-6-funcapp.bicep' = {
  name: 'functionappdeploy'
  params: {
    appInsightsInstrumentationKey: appinsightsmod.outputs.appInsightsInstrumentationKey
    functionAppServiceName: functionAppServiceName
    functionAppName: functionAppName
    defaultTags: defaultTags
  }
}

// Create Azure KeyVault
//module keyvault 'main-8-keyvault.bicep' = {
//  name: 'keyvaultdeploy'
//  params: {
//    vaultName: keyvaultNamev2
//    sqlserverName: sqlserverName
//    sqlDBName: sqlDBName
//    sqlAdministratorLogin: sqlAdministratorLogin
//    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
//  }

//}

// Create APIM.  NOTE: MUST MOVE THIS. APIM + Azure KeyVault, needs to be in it's own RG + Pipeline
module apiservicesmod './main-7-apimanagement.bicep' = {
  name: 'apiservicesdeploy'
  params: {
    apiServiceName: apiServiceName
    defaultTags: defaultTags
  }
}

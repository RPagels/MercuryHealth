// Deploy Azure infrastructure for app + data + monitoring

//targetScope = 'subscription'
// Region for all resources
param location string = resourceGroup().location
param environment string = 'dev'
param createdBy string = 'Randy Pagels'
param costCenter string = '74f644d3e665'

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

// Avoid outputs for secrets - Look up secrets dynamically
resource config 'Microsoft.AppConfiguration/configurationStores@2021-03-01-preview' existing = {
  name: configStoreName
}
var configStoreConnectionString = listKeys(config.id, config.apiVersion).value[0].connectionString

// Lock Resoure Group
resource dontDeleteLock 'Microsoft.Authorization/locks@2020-05-01' = {
  name: 'DontDeleteMe'
  properties: {
    level: 'CanNotDelete'
    notes: 'Prevent deletion of the resource group'
  }
}

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
    appInsightsInstrumentationKey: appinsightsmod.outputs.appInsightsInstrumentationKey
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
   appInsightsInstrumentationKey: appinsightsmod.outputs.appInsightsInstrumentationKey
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

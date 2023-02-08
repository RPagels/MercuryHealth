// Deploy Azure infrastructure for app + data + monitoring

//targetScope = 'subscription'
// Region for all resources
param location string = resourceGroup().location
param createdBy string = 'Randy Pagels' // resourceGroup().managedBy
param costCenter string = '74f644d3e665'
param releaseAnnotationGuid string = newGuid()
param Deployed_Environment string

// Generate Azure SQL Credentials
var sqlAdminLoginName = 'AzureAdmin'
var sqlAdminLoginPassword = '${substring(base64(uniqueString(resourceGroup().id)), 0, 10)}.${uniqueString(resourceGroup().id)}'

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
var loadTests2ndLocation = 'northeurope'
var loadTests2ndName = 'loadtests-${uniqueString(resourceGroup().id)}-${loadTests2ndLocation}'
var keyvaultName = 'kv-${uniqueString(resourceGroup().id)}'
var blobstorageName = 'stablob${uniqueString(resourceGroup().id)}'
//var dashboardName = 'dashboard-${uniqueString(resourceGroup().id)}'
var frontDoorName = 'fd-${uniqueString(resourceGroup().id)}'
var logicAppName = 'logic-${uniqueString(resourceGroup().id)}'
var cognitiveServiceName = 'cog-${uniqueString(resourceGroup().id)}'


// Tags
var defaultTags = {
  Env: Deployed_Environment
  App: 'Mercury Health'
  CostCenter: costCenter
  CreatedBy: createdBy
}

// KeyVault Secret Names
param kvValue_configStoreConnectionName string = 'ConnectionStringsAppConfig'
param kvValue_ConnectionStringName string = 'ConnectionStringsMercuryHealthWebContext'
param kvValue_AzureWebJobsStorageName string = 'AzureWebJobsStorage'
param kvValue_WebsiteContentAzureFileConnectionString string = 'WebsiteContentAzureFileConnectionString'
param kvValue_ApimSubscriptionKeyName string = 'ApimSubscriptionKey'

// App Configuration Settings
var FontNameKey = 'FontName'
var FontColorKey = 'FontColor'
var FontSizeKey = 'FontSize'
var FontNameValue = 'Calibri'
var FontColorValue = 'Black'
var FontSizeValue = '14'

// Create Azure KeyVault
module keyvaultmod './main-8-keyvault.bicep' = {
  name: keyvaultName
  params: {
    location: location
    vaultName: keyvaultName
    }
 }
 
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
    functionAppServiceName: functionAppServiceName
    functionAppName: functionAppName
    defaultTags: defaultTags
  }
  dependsOn:  [
    appinsightsmod
  ]
}

// Create API Management
module apimservicemod './main-7-apimanagement.bicep' = {
  name: apiServiceName
    params: {
    location: location
    defaultTags: defaultTags
    apiServiceName: apiServiceName
    appInsightsName: appInsightsName
    applicationInsightsID: appinsightsmod.outputs.out_applicationInsightsID
    appInsightsInstrumentationKey: appinsightsmod.outputs.out_appInsightsInstrumentationKey
    webSiteName: webSiteName
    
  }
  dependsOn:  [
    appinsightsmod
  ]
}

// Create Azure Load Tests
module loadtestsmod './main-9-loadtests.bicep' = {
  name: loadTestsName
  params: {
    location: location
    loadTestsName: loadTestsName
    loadTests2ndLocation: loadTests2ndLocation
    loadTests2ndName: loadTests2ndName
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

module configstoremod './main-5-configstore.bicep' = {
  name: configStoreName
  params: {
    location: location
     defaultTags: defaultTags
     configStoreName: configStoreName
     FontNameKey: FontNameKey
     FontNameValue: FontNameValue
     FontColorKey: FontColorKey
     FontColorValue: FontColorValue
     FontSizeKey: FontSizeKey
     FontSizeValue: FontSizeValue
  }
  dependsOn:  [
    webappmod
    functionappmod
  ]
}

// module logicappmod './main-15-logicapp.bicep' = {
//   name: logicAppName
//   params: {
//     defaultTags: defaultTags
//     logicAppName: logicAppName
//     location: location
//     // connections_office365_externalid: connections_office365_externalid
//     // connections_sql_externalid: connections_sql_externalid
//     // connections_teams_externalid: connections_teams_externalid
//   }
// }

// module cognitiveservicemod 'main-16-cognitiveservice.bicep' = {
//   name: cognitiveServiceName
//   params: {
//     defaultTags: defaultTags
//     cognitiveServiceName: cognitiveServiceName
//     location: location
//   }
// }

// module portaldashboardmod './main-11-Dashboard.bicep' = {
//   name: dashboardName
//   params: {
//     location: location
//     appInsightsName: appInsightsName
//     dashboardName: dashboardName
//   }
// }

//param AzObjectIdPagels string = 'b6be0700-1fda-4f88-bf20-1aa508a91f73'
param AzObjectIdPagels string = '197b8610-80f8-4317-b9c4-06e5b3246e87'

// Application Id of Service Principal "MercuryHealth_ServicePrincipal"
//param ADOServiceprincipalObjectId string = '5bc20bf4-172c-48ac-86e7-a5185394237b'
//aram ADOServiceprincipalObjectId string = 'e7f4d4b8-26e0-452a-868f-6818be23ef73'
param ADOServiceprincipalObjectId string = '61ad559f-a07a-4d8f-981b-c88e69216dd1'

// Create Configuration Entries
module configsettingsmod './main-13-configsettings.bicep' = {
  name: 'configSettings'
  params: {
    keyvaultName: keyvaultName
    kvValue_configStoreConnectionName: kvValue_configStoreConnectionName
    kvValue_configStoreConnectionValue: configstoremod.outputs.out_configStoreConnectionString
    kvValue_ConnectionStringName: kvValue_ConnectionStringName
    kvValue_ConnectionStringValue: webappmod.outputs.out_secretConnectionString
    appServiceprincipalId: webappmod.outputs.out_appServiceprincipalId
    webappName: webSiteName
    functionAppName: functionAppName
    funcAppServiceprincipalId: functionappmod.outputs.out_funcAppServiceprincipalId
    configStoreEndPoint: configstoremod.outputs.out_configStoreEndPoint
    configStoreName: configStoreName
    FontNameKey: FontNameKey
    FontColorKey: FontColorKey
    FontSizeKey: FontSizeKey
    kvValue_AzureWebJobsStorageName: kvValue_AzureWebJobsStorageName
    kvValue_AzureWebJobsStorageValue: functionappmod.outputs.out_AzureWebJobsStorage
    kvValue_WebsiteContentAzureFileConnectionStringName: kvValue_WebsiteContentAzureFileConnectionString
    kvValue_ApimSubscriptionKeyName: kvValue_ApimSubscriptionKeyName
    kvValue_ApimSubscriptionKeyValue: apimservicemod.outputs.out_ApimSubscriptionKeyString
    appInsightsInstrumentationKey: appinsightsmod.outputs.out_appInsightsInstrumentationKey
    appInsightsConnectionString: appinsightsmod.outputs.out_appInsightsConnectionString
    Deployed_Environment: Deployed_Environment
    ApimWebServiceURL: apimservicemod.outputs.out_ApimWebServiceURL
    AzObjectIdPagels: AzObjectIdPagels
    ADOServiceprincipalObjectId: ADOServiceprincipalObjectId
    }
    dependsOn:  [
     keyvaultmod
     webappmod
     functionappmod
     configstoremod
   ]
 }

 // Create Front Door
module frontdoormod './main-14-frontdoor.bicep' = {
  name: frontDoorName
  params: {
  backendAddress: '${apiServiceName}.azure-api.net'  //
  frontDoorName: frontDoorName
  }
}

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
output out_loadTests2ndName string = loadTests2ndName
output out_apimSubscriptionKey string = apimservicemod.outputs.out_ApimSubscriptionKeyString
output out_keyvaultName string = keyvaultName
output out_secretConnectionString string = webappmod.outputs.out_secretConnectionString
output out_appInsightsApplicationId string = appinsightsmod.outputs.out_appInsightsApplicationId
output out_appInsightsAPIApplicationId string = appinsightsmod.outputs.out_appInsightsAPIApplicationId
output out_releaseAnnotationGuidID string = releaseAnnotationGuid

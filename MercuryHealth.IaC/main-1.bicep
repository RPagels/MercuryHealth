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
var apiServiceName = 'apim-${uniqueString(resourceGroup().id)}'
var loadTestsName = 'loadtests-${uniqueString(resourceGroup().id)}'
var keyvaultName = 'kv-${uniqueString(resourceGroup().id)}'
var blobstorageName = 'stablob${uniqueString(resourceGroup().id)}'
//var dashboardName = 'dashboard-${uniqueString(resourceGroup().id)}'
var frontDoorName = 'fd-${uniqueString(resourceGroup().id)}'

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

///////////////////////////
/// TESTING App Config
///////////////////////////
var FontNameKey = 'FontName'
var FontColorKey = 'FontColor'
var FontSizeKey = 'FontSize'
var FontNameValue = 'Calibri'
var FontColorValue = 'Blue'
var FontSizeValue = '12'
//var myLabel = 'Test'
//var App_Configuration_Data_Reader = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/516239f1-63e1-4d78-a4de-a74fb236a071'
///////////////////////////
/// TESTING App Config
///////////////////////////

////////////////////////////////////////
// BEGIN - Create Config Store
////////////////////////////////////////

// @description('Specifies the content type of the key-value resources. For feature flag, the value should be application/vnd.microsoft.appconfig.ff+json;charset=utf-8. For Key Value reference, the value should be application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8. Otherwise, it\'s optional.')
// param contentType string = 'application/vnd.microsoft.appconfig.ff+json;charset=utf-8'

// // Specifies the names of the key-value resources. 
// param ConfigkeyValueNames array = [
//   'App:Settings:FontSize'
//   'App:Settings:FontColor'
//   'App:Settings:BackgroundColor'
//   'App:Settings:Sentinel'
// ]

// // Specifies the values of the key-value resources. #000=Black, #FFF=White
// param ConfigkeyKeyValues array = [
//   '13'
//   'black'
//   'white'
//   '1'
// ]

// param FeatureFlagKey1 string = 'PrivacyBeta'
// param FeatureFlagKey2 string = 'MetricsDashboard'
// param FeatureFlagKey3 string = 'NutritionColor'
// param FeatureFlagKey4 string = 'MetricsDashboard2'
// param FeatureFlagLabel1 string = 'Privacy Beta'
// param FeatureFlagLabel2 string = 'Metrics Dashboard'
// param FeatureFlagLabel3 string = 'Nutrition Color'
// param FeatureFlagLabel4 string = ''

// var FeatureFlagValue1 = {
//   id: FeatureFlagKey1
//   description: 'Description for Privacy Beta.'
//   enabled: true
// }
// var FeatureFlagValue2 = {
//   id: FeatureFlagKey2
//   description: 'Description for Metrics Dashboard.'
//   enabled: true
// }
// var FeatureFlagValue3 = {
//   id: FeatureFlagKey3
//   description: 'Description for Nutrition Color.'
//   enabled: false
// }
// var FeatureFlagValue4 = {
//   id: FeatureFlagKey4
//   description: 'Description for Metrics Dashboard 2.'
//   enabled: true
// }

// Create AppConfiguration configuration Store
// enableSoftDelete: false
// resource config 'Microsoft.AppConfiguration/configurationStores@2022-05-01' = {
//   name: configStoreName
//   location: location
//   tags: defaultTags
//   properties: {
//     enablePurgeProtection: false
//     softDeleteRetentionInDays: 7
//   }
//   sku: {
//     name: 'Standard'
//   }
// }

// Loop through array and create Config Key Values
// resource configStoreName_keyValueNames 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = [for (item, i) in ConfigkeyValueNames: {
//   name: '${config.name}/${item}' //'${config.name}/${item}'
//   properties: {
//     value: ConfigkeyKeyValues[i]
//     //contentType: contentType
//     tags: defaultTags
//   }
// }]

// Feature Flag 1
// resource configStoreName_appconfig_featureflags_1 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
//   parent: config
//   name: '.appconfig.featureflag~2F${FeatureFlagKey1}$${FeatureFlagLabel1}'
//   properties: {
//     value: string(FeatureFlagValue1)
//     contentType: contentType
//   }
// }
// Feature Flag 2
// resource configStoreName_appconfig_featureflags_2 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
//   parent: config
//   name: '.appconfig.featureflag~2F${FeatureFlagKey2}$${FeatureFlagLabel2}'
//   properties: {
//     value: string(FeatureFlagValue2)
//     contentType: contentType
//   }
// }
// Feature Flag 3
// resource configStoreName_appconfig_featureflags_3 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
//   parent: config
//   name: '.appconfig.featureflag~2F${FeatureFlagKey3}$${FeatureFlagLabel3}'
//   properties: {
//     value: string(FeatureFlagValue3)
//     contentType: contentType
//   }
// }

// resource configStoreName_appconfig_featureflags_4 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
//   parent: config
//   name: '.appconfig.featureflag~2F${FeatureFlagKey4}$${FeatureFlagLabel4}'
//   properties: {
//     value: string(FeatureFlagValue4)
//     contentType: contentType
//   }
// }

// AppConfiguration - Avoid outputs for secrets - Look up secrets dynamically
// https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/scenarios-secrets
// Note: This is why ConfigStore isn't it's own module...MUST be in the main
//var configStoreConnectionString = listKeys(config.id, config.apiVersion).value[0].connectionString

////////////////////////////////////////
// END - Setup Config Store
////////////////////////////////////////

// Create Azure KeyVault
module keyvaultmod './main-8-keyvault.bicep' = {
  name: keyvaultName
  params: {
    location: location
    vaultName: keyvaultName
    }
 }
 
// AppConfiguration - Avoid outputs for secrets - Look up secrets dynamically
// https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/scenarios-secrets
// Note: This is why ConfigStore isn't it's own module...MUST be in the main
//var configStoreConnectionString = listKeys(config.id, config.apiVersion).value[0].connectionString

@minLength(1)
param publisherEmail string = 'rpagels@microsoft.com'
@minLength(1)
param publisherName string = 'Randy Pagels'
param sku string = 'Developer' // 'Developer' or 'Consumption'
param skuCount int = 1  // Developr = 1, Consumption = 0

// Create the API Service
resource apiManagementService 'Microsoft.ApiManagement/service@2021-12-01-preview' = {
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

// Create the Subscription for Developers
resource apiManagementSubscription 'Microsoft.ApiManagement/service/subscriptions@2021-12-01-preview' = {
  parent: apiManagementService
  name: 'developers'
  properties: {
    scope: '/apis' // Subscription applies to all APIs
    displayName: 'Mercury Health - Developers'
    state: 'active'
  }
}

// Create the Product
resource apiManagementProduct 'Microsoft.ApiManagement/service/products@2021-12-01-preview' = {
  parent: apiManagementService
  name: 'development'
  properties: {
    approvalRequired: false
    state: 'published'
    subscriptionRequired: true
    subscriptionsLimit: 1
    description: 'Product used for Mercury Health Development Teams'
    displayName: 'Mercury Health - Developers'
     terms: 'These are the terms of use ...'
  }
}

// Create the Product Policies
resource apiManagementProductPolicies 'Microsoft.ApiManagement/service/products/policies@2021-12-01-preview' = {
  name: 'policy'
  parent: apiManagementProduct
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <rate-limit calls="5" renewal-period="60" />\r\n    <quota calls="100" renewal-period="604800" />\r\n    <base />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
}

// Create the API Logger for Application Insights
resource appInsightsAPILogger 'Microsoft.ApiManagement/service/loggers@2021-12-01-preview' = {
  parent: apiManagementService
  name: appInsightsName // 'MercuryHealth-applicationinsights'
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

// Import API Example
resource petStoreApiExample 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
  name: 'pet-store-swagger'
  //name: '${apiManagement.name}/PetStoreSwaggerImportExample'
  parent: apiManagementService
  properties: {
    format: 'swagger-link-json'
    value: 'http://petstore.swagger.io/v2/swagger.json'
    path: 'petstore'
    description: 'Pet Store Swagger Import Example'
  }
}

//
// Mercury Health Swagger
//
@allowed([
  'yaml-v3' //uses 'openapi-link' format
  'json-v3' //uses 'openapi+json-link' format
])
param swaggerType string = 'yaml-v3'

// This url needs to be reachable for APIM
param urlToSwagger string = 'https://raw.githubusercontent.com/RPagels/MercuryHealth/master/MercuryHealth.IaC/MercuryHealth.openapi.yaml'
//param urlToSwagger string = './MercuryHealth.IaC/MercuryHealth.openapi.yaml'
param apiPath string = '' // There can be only one api without path
param name string = 'mercury-health'
var format = ((swaggerType == 'yaml-v3')  ? 'openapi-link' : 'openapi+json-link')

// Create APIs from template
resource apiManagementMercuryHealthImport 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
  name: '${apiManagementService.name}/${name}'
  properties: {
    format: format
    value: urlToSwagger // OR value: loadTextContent('./MercuryHealth.swagger.json')
    path: apiPath
    displayName: 'Mercury Health'
    serviceUrl: 'https://${webSiteName}.azurewebsites.net/'
  }
}
//
// Mercury Health Swagger
//

// Create the Product for API
resource apiManagementProductApi 'Microsoft.ApiManagement/service/products/apis@2017-03-01' = {
  parent: apiManagementProduct
  name: 'mercury-health'
  dependsOn: [
    apiManagementMercuryHealthImport
  ]
}

// Create reference to existing API
resource apiManagementMercuryHealthApis 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' existing = {
  name: 'mercury-health'
  parent: apiManagementService
}

// Create reference to existing API
resource apiManagementPetStoreApis 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' existing = {
  name: 'pet-store-swagger' // 'api' PetStoreSwaggerImportExample
  parent: apiManagementService
}

// Configure logging for the API
resource appInsightsAPIPetStorediagnostics 'Microsoft.ApiManagement/service/apis/diagnostics@2021-12-01-preview' = {
  parent: apiManagementPetStoreApis
  name: 'applicationinsights'
  properties: {
    loggerId: appInsightsAPILogger.id
    alwaysLog: 'allErrors'
    logClientIp: true
    sampling: {
      samplingType: 'fixed'
      percentage: 100
    }
    verbosity: 'information'
    httpCorrelationProtocol: 'Legacy'
    frontend: {
      request: {
        headers: []
        body: {
          bytes: 0
        }
      }
      response: {
        headers: []
        body: {
          bytes: 0
        }
      }
    }
    backend: {
      request: {
        headers: []
        body: {
          bytes: 0
        }
      }
      response: {
        headers: []
        body: {
          bytes: 0
        }
      }
    }
  }
  dependsOn:  [
    appinsightsmod
  ]
}

// Configure logging for the API.
resource appInsightsAPIMercuryHealthdiagnostics 'Microsoft.ApiManagement/service/apis/diagnostics@2021-12-01-preview' = {
  parent: apiManagementMercuryHealthApis
  name: 'applicationinsights'
  properties: {
    loggerId: appInsightsAPILogger.id
    alwaysLog: 'allErrors'
    logClientIp: true
    sampling: {
      samplingType: 'fixed'
      percentage: 100
    }
    verbosity: 'information'
    httpCorrelationProtocol: 'Legacy'
    frontend: {
      request: {
        headers: []
        body: {
          bytes: 0
        }
      }
      response: {
        headers: []
        body: {
          bytes: 0
        }
      }
    }
    backend: {
      request: {
        headers: []
        body: {
          bytes: 0
        }
      }
      response: {
        headers: []
        body: {
          bytes: 0
        }
      }
    }
  }
  dependsOn:  [
    appinsightsmod
  ]
}

resource apiManagementServiceName_exampleUser1 'Microsoft.ApiManagement/service/users@2017-03-01' = {
  parent: apiManagementService
  name: 'exampleUser1'
  properties: {
    firstName: 'ExampleFirstName1'
    lastName: 'ExampleLastName1'
    email: 'ExampleFirst1@example.com'
    state: 'active'
    note: 'note for example user 1'
  }
}

resource apiManagementServiceName_examplesubscription1 'Microsoft.ApiManagement/service/subscriptions@2017-03-01' = {
  parent: apiManagementService
  name: 'examplesubscription1'
  properties: {
    displayName: 'exampleUser1DisplayName'
    productId: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ApiManagement/service/exampleServiceName/products/development'
    userId: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ApiManagement/service/exampleServiceName/users/exampleUser1'
  }
  dependsOn: [
    apiManagementProduct
    apiManagementServiceName_exampleUser1
  ]
}

// API Management - Avoid outputs for secrets - Look up secrets dynamically
// Note: This is why API Management isn't it's own module...MUST be in the main
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

module configstoremod 'main-5-configstore.bicep' = {
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
}

// module portaldashboardmod './main-11-Dashboard.bicep' = {
//   name: dashboardName
//   params: {
//     location: location
//     appInsightsName: appInsightsName
//     dashboardName: dashboardName
//   }
// }

param AzObjectIdPagels string = 'b6be0700-1fda-4f88-bf20-1aa508a91f73'

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
    configStoreprincipalId: configstoremod.outputs.out_configStoreprincipalId
    configStoreObject: configstoremod
    FontNameKey: FontNameKey
    FontColorKey: FontColorKey
    FontSizeKey: FontSizeKey
    kvValue_AzureWebJobsStorageName: kvValue_AzureWebJobsStorageName
    kvValue_AzureWebJobsStorageValue: functionappmod.outputs.out_AzureWebJobsStorage
    kvValue_WebsiteContentAzureFileConnectionStringName: kvValue_WebsiteContentAzureFileConnectionString
    appInsightsInstrumentationKey: appinsightsmod.outputs.out_appInsightsInstrumentationKey
    appInsightsConnectionString: appinsightsmod.outputs.out_appInsightsConnectionString
    Deployed_Environment: Deployed_Environment
    ApimSubscriptionKey: ApimSubscriptionKeyString
    ApimWebServiceURL: apiManagementService.properties.gatewayUrl
    AzObjectIdPagels: AzObjectIdPagels
    }
    dependsOn:  [
     keyvaultmod
     webappmod
     functionappmod
   ]
 }

 // Create Front Door
module frontdoormod './main-14-frontdoor.bicep' = {
  name: frontDoorName
  params: {
  //backendAddress: 'https://${webSiteName}.azurewebsites.net/'
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
output out_keyvaultName string = keyvaultName
output out_secretConnectionString string = webappmod.outputs.out_secretConnectionString
output out_appInsightsApplicationId string = appinsightsmod.outputs.out_appInsightsApplicationId
output out_appInsightsAPIApplicationId string = appinsightsmod.outputs.out_appInsightsAPIApplicationId
output out_releaseAnnotationGuidID string = releaseAnnotationGuid

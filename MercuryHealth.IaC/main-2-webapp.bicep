param skuName string = 'S1'
//param skuCapacity int = 1
param location string = resourceGroup().location
param sqlserverName string
param sqlserverfullyQualifiedDomainName string
param sqlDBName string
param sqlAdministratorLogin string
param sqlAdministratorLoginPassword string
param webAppPlanName string
param webSiteName string
param configStoreEndpoint string
param appInsightsInstrumentationKey string
param appInsightsConnectionString string
param defaultTags object

// Varabiles
var standardPlanMaxAdditionalSlots = 3
param environments array = [
  'Dev'
  'QA'
  'UAT'
]

resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: webAppPlanName // app serivce plan name
  location: location // Azure Region
  tags: defaultTags
  // tags: {
  //   //displayName: 'AppServicePlan'
  //   //ProjectName: webSiteName
  //   defaultTags
  // }
  properties: {}
  sku: {
    name: ((length(environments) <= standardPlanMaxAdditionalSlots) ? skuName : 'P1')
  }
}

resource appService 'Microsoft.Web/sites@2021-01-15' = {
  name: webSiteName // Globally unique app serivce name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: defaultTags
  // tags: {
  //   displayName: 'Website'
  //   ProjectName: webSiteName
  // }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      minTlsVersion: '1.2'
    }
  }
}

// resource webSiteConnectionStrings 'Microsoft.Web/sites/config@2021-01-15' = {
//   name: '${webSiteName}/connectionstrings'
//   properties: {
//     DefaultConnection: {
//       value: 'Data Source=tcp:${sqlserverName},1433;Initial Catalog=${sqlDBName};User Id=${sqlAdministratorLogin}@${sqlserverName};Password=${sqlAdministratorLoginPassword};'
//       type: 'SQLAzure'
//     }
//   }
//   dependsOn: [
//     appService
//   ]
// }
  
resource webSiteAppSettingsStrings 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${webSiteName}/appsettings'
  properties: {
    'ConnectionStrings:DefaultConnection': 'Data Source=tcp:${sqlserverfullyQualifiedDomainName},1433;Initial Catalog=${sqlDBName};Persist Security Info=False;User Id=${sqlAdministratorLogin}@${sqlserverName};Password=${sqlAdministratorLoginPassword};'
    'ApimSubscriptionKey': 'e2d1cf7c...for APIM - TBD'
    'ConnectionStrings:AppConfig': configStoreEndpoint
    'Environment': 'Prod'
    'WEBSITE_RUN_FROM_PACKAGE': '1'
    'APPINSIGHTS_INSTRUMENTATIONKEY': appInsightsInstrumentationKey
    'APPINSIGHTS_PROFILERFEATURE_VERSION': '1.0.0'
    'APPINSIGHTS_SNAPSHOTFEATURE_VERSION': '1.0.0'
    'APPLICATIONINSIGHTS_CONNECTION_STRING': appInsightsConnectionString
    type: 'SQLAzure'
  }
  dependsOn: [
    appService
  ]
}

resource webAppPortalName_environments 'Microsoft.Web/sites/slots@2020-06-01' = [for item in environments: {
  name: '${webSiteName}/${item}'
  kind: 'app'
  location: location
  tags: defaultTags
  // tags: {
  //   displayName: 'WebAppSlots'
  // }
  properties: {
    serverFarmId: appServicePlan.id
  }
  dependsOn: [
    appService
  ]
}]

output webSiteName string = appService.name
output webSiteURL string = appService.properties.defaultHostName

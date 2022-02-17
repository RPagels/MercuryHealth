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
param resourceGroupName string
param appInsightsName string

//param configStoreEndpoint string

//@secure()
param configStoreConnection string

param appInsightsInstrumentationKey string
param appInsightsConnectionString string
param defaultTags object
//param testName string = 'testName'

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

resource webSiteAppSettingsStrings 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${webSiteName}/appsettings'
  properties: {
    'ConnectionStrings:MercuryHealthWebContext': 'Server=tcp:${sqlserverfullyQualifiedDomainName},1433;Initial Catalog=${sqlDBName};Persist Security Info=False;User Id=${sqlAdministratorLogin}@${sqlserverName};Password=${sqlAdministratorLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
    'ApimSubscriptionKey': 'e2d1cf7c...for APIM - TBD'
    'ConnectionStrings:AppConfig': configStoreConnection
    'Environment': 'Prod'
    'WEBSITE_RUN_FROM_PACKAGE': '1'
    'APPINSIGHTS_INSTRUMENTATIONKEY': appInsightsInstrumentationKey
    'APPINSIGHTS_PROFILERFEATURE_VERSION': '1.0.0'
    'APPINSIGHTS_SNAPSHOTFEATURE_VERSION': '1.0.0'
    'APPLICATIONINSIGHTS_CONNECTION_STRING': appInsightsConnectionString
    'Debug ONLY': 'appInsightsName=${appInsightsName}'
    type: 'SQLAzure'
  }
  dependsOn: [
    appService
  ]
}

// resource webAppPortalName_environments 'Microsoft.Web/sites/slots@2021-02-01' = [for item in environments: {
//   name: '${webSiteName}/${item}'
//   kind: 'app'
//   location: location
//   tags: defaultTags
//   // tags: {
//   //   displayName: 'WebAppSlots'
//   // }
//   properties: {
//     serverFarmId: appServicePlan.id
//   }
//   dependsOn: [
//     appService
//   ]
// }]

// UPDATE THE Web Tests!!!
// resourceGroup().id
// appInsightsName
//

// Does not work!!!
// resource standardWebTestPageHome  'Microsoft.Insights/webtests@2020-10-05-preview' = {
//   name: 'appInsights-PageHome'
//   location: 'eastus'
//   tags: {
//     'hidden-link:/subscriptions/f5e66d29-1a7f-4ee3-822e-74f644d3e665/resourceGroups/${resourceGroupName}/providers/microsoft.insights/components/${appInsightsName}': 'Resource'
//   }
//   kind: 'ping'
//   properties: {
//     SyntheticMonitorId: appInsightsName
//     Name: 'appInsights-Page Home'
//     Description: null
//     Enabled: true
//     Frequency: 900
//     Timeout: 120 
//     Kind: 'standard'
//     RetryEnabled: true
//     Locations: [
//       {
//         Id: 'emea-nl-ams-azr'
//       }
//       {
//         Id: 'emea-ru-msa-edge'
//       }
//       {
//         Id: 'apac-hk-hkn-azr'
//       }
//       {
//         Id: 'latam-br-gru-edge'
//       }
//       {
//         Id: 'emea-au-syd-edge'
//       }
//     ]
//     Configuration: null
//     Request: {
//       RequestUrl: '${appService.properties.defaultHostName}' // 'https://website-4vwxkvpofrtbq-dev.azurewebsites.net/'
//       Headers: null
//       HttpVerb: 'GET'
//       RequestBody: null
//       ParseDependentRequests: false
//       FollowRedirects: null
//     }
//     ValidationRules: {
//       ExpectedHttpStatusCode: 200
//       IgnoreHttpsStatusCode: false
//       ContentValidation: null
//       SSLCheck: true
//       SSLCertRemainingLifetimeCheck: 7
//     }
//   }
// }

// Works!!!
// MercuryHealth-rg - appInsights-4vwxkvpofrtbq
resource standardWebTestPageHome  'Microsoft.Insights/webtests@2020-10-05-preview' = {
  name: 'appInsights-Page Home'
  location: location
  tags: {
    // Error: A single 'hidden-link' tag pointing to an existing AI component is required. Found none.
    'hidden-link:/subscriptions/f5e66d29-1a7f-4ee3-822e-74f644d3e665/resourceGroups/${resourceGroupName}/providers/microsoft.insights/components/appInsights-4vwxkvpofrtbq': 'Resource'
    //'hidden-link:/subscriptions/f5e66d29-1a7f-4ee3-822e-74f644d3e665/resourceGroups/MercuryHealth-rg/providers/microsoft.insights/components/${appInsightsName}': 'Resource'
  }
  kind: 'ping'
  properties: {
    SyntheticMonitorId: appInsightsName
    Name: 'appInsights-Page Home'
    Description: null
    Enabled: true
    Frequency: 900
    Timeout: 120 
    Kind: 'standard'
    RetryEnabled: true
    Locations: [
      {
        Id: 'emea-nl-ams-azr'
      }
      {
        Id: 'emea-ru-msa-edge'
      }
      {
        Id: 'apac-hk-hkn-azr'
      }
      {
        Id: 'latam-br-gru-edge'
      }
      {
        Id: 'emea-au-syd-edge'
      }
    ]
    Configuration: null
    Request: {
      RequestUrl: 'https://${appService.name}.azurewebsites.net'
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
  name: 'appInsights-Page Nutritions'
  location: location
  tags: {
    'hidden-link:/subscriptions/f5e66d29-1a7f-4ee3-822e-74f644d3e665/resourceGroups/MercuryHealth-rg/providers/microsoft.insights/components/appInsights-4vwxkvpofrtbq': 'Resource'
  }
  kind: 'ping'
  properties: {
    SyntheticMonitorId: appInsightsInstrumentationKey // 'appInsights-4vwxkvpofrtbq'
    Name: 'appInsights-Page Nutritions'
    Description: null
    Enabled: true
    Frequency: 900
    Timeout: 120 
    Kind: 'standard'
    RetryEnabled: true
    Locations: [
      {
        Id: 'emea-nl-ams-azr'
      }
      {
        Id: 'emea-ru-msa-edge'
      }
      {
        Id: 'apac-hk-hkn-azr'
      }
      {
        Id: 'latam-br-gru-edge'
      }
      {
        Id: 'emea-au-syd-edge'
      }
    ]
    Configuration: null
    Request: {
      RequestUrl: 'https://${appService.name}.azurewebsites.net/Nutritions' //'https://website-4vwxkvpofrtbq-dev.azurewebsites.net/Nutritions'
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
  name: 'appInsights-Page Exercises'
  location: location
  tags: {
    'hidden-link:/subscriptions/f5e66d29-1a7f-4ee3-822e-74f644d3e665/resourceGroups/MercuryHealth-rg/providers/microsoft.insights/components/appInsights-4vwxkvpofrtbq': 'Resource'
  }
  kind: 'ping'
  properties: {
    SyntheticMonitorId: appInsightsName //'appInsights-4vwxkvpofrtbq'
    Name: 'appInsights-Page Exercises'
    Description: null
    Enabled: true
    Frequency: 900
    Timeout: 120 
    Kind: 'standard'
    RetryEnabled: true
    Locations: [
      {
        Id: 'emea-nl-ams-azr'
      }
      {
        Id: 'emea-ru-msa-edge'
      }
      {
        Id: 'apac-hk-hkn-azr'
      }
      {
        Id: 'latam-br-gru-edge'
      }
      {
        Id: 'emea-au-syd-edge'
      }
    ]
    Configuration: null
    Request: {
      RequestUrl: 'https://${appService.name}.azurewebsites.net/Exercises' //'https://website-4vwxkvpofrtbq-dev.azurewebsites.net/Exercises'
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

output webSiteName string = appService.name
output webSiteURL string = appService.properties.defaultHostName

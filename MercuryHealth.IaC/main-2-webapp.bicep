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
//param configStoreEndpoint string
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
    'ConnectionStrings:DefaultConnection': 'Server=tcp:${sqlserverfullyQualifiedDomainName},1433;Initial Catalog=${sqlDBName};Persist Security Info=False;User Id=${sqlAdministratorLogin}@${sqlserverName};Password=${sqlAdministratorLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
    'ApimSubscriptionKey': 'e2d1cf7c...for APIM - TBD'
    'ConnectionStrings:AppConfig': configStoreConnection //configStoreEndpoint
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

//  resource testName_resource 'Microsoft.Insights/webtests@2015-05-01' = {
//   name: testName
//   location: location
//   // tags: {
//   //   'hidden-link:${resourceId('microsoft.insights/components', componentName)}': 'Resource'
//   // }
//   properties: {
//     SyntheticMonitorId: testName
//     Name: testName
//     Enabled: true
//     Frequency: 300
//     Timeout: 120
//     Kind: 'ping'
//     RetryEnabled: false
//     Locations: testLocations
//     Configuration: {
//       WebTest: '<WebTest         Name="${testName}"         Id="00000000-0000-0000-0000-000000000000"         Enabled="True"         CssProjectStructure=""         CssIteration=""         Timeout="120"         WorkItemIds=""         xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010"         Description=""         CredentialUserName=""         CredentialPassword=""         PreAuthenticate="True"         Proxy="default"         StopOnError="False"         RecordedResultFile=""         ResultsLocale="">        <Items>        <Request         Method="GET"         Guid="a86e39d1-b852-55ed-a079-23844e235d01"         Version="1.1"         Url="${testEndpoint}"         ThinkTime="0"         Timeout="120"         ParseDependentRequests="False"         FollowRedirects="True"         RecordResult="True"         Cache="False"         ResponseTimeGoal="0"         Encoding="utf-8"         ExpectedHttpStatusCode="200"         ExpectedResponseUrl=""         ReportingName=""         IgnoreHttpStatusCode="False" />        </Items>        </WebTest>'
//     }
//   }
// }

resource standardWebTestPageHome  'Microsoft.Insights/webtests@2020-10-05-preview' = {
  name: 'appInsights-PageHome'
  location: 'eastus'
  tags: {
    'hidden-link:/subscriptions/f5e66d29-1a7f-4ee3-822e-74f644d3e665/resourceGroups/MercuryHealth-rg/providers/microsoft.insights/components/appInsights-4vwxkvpofrtbq': 'Resource'
  }
  kind: 'ping'
  properties: {
    SyntheticMonitorId: 'appInsights-4vwxkvpofrtbq'
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
      RequestUrl: 'https://website-4vwxkvpofrtbq-dev.azurewebsites.net/'
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
  dependsOn: [
   appService
  ]
}

resource standardWebTestPageNutritions  'Microsoft.Insights/webtests@2020-10-05-preview' = {
  name: 'appInsights-Page Nutritions'
  location: 'eastus'
  tags: {
    'hidden-link:/subscriptions/f5e66d29-1a7f-4ee3-822e-74f644d3e665/resourceGroups/MercuryHealth-rg/providers/microsoft.insights/components/appInsights-4vwxkvpofrtbq': 'Resource'
  }
  kind: 'ping'
  properties: {
    SyntheticMonitorId: 'appInsights-4vwxkvpofrtbq'
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
      RequestUrl: 'https://website-4vwxkvpofrtbq-dev.azurewebsites.net/Nutritions'
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
  dependsOn: [
   appService
  ]
}

resource standardWebTestPageExercises  'Microsoft.Insights/webtests@2020-10-05-preview' = {
  name: 'appInsights-Page Exercises'
  location: 'eastus'
  tags: {
    'hidden-link:/subscriptions/f5e66d29-1a7f-4ee3-822e-74f644d3e665/resourceGroups/MercuryHealth-rg/providers/microsoft.insights/components/appInsights-4vwxkvpofrtbq': 'Resource'
  }
  kind: 'ping'
  properties: {
    SyntheticMonitorId: 'appInsights-4vwxkvpofrtbq'
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
      RequestUrl: 'https://website-4vwxkvpofrtbq-dev.azurewebsites.net/Exercises'
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
  dependsOn: [
   appService
  ]
}

output webSiteName string = appService.name
output webSiteURL string = appService.properties.defaultHostName

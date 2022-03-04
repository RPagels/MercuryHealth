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

//@secure()
param configStoreConnection string

param appInsightsInstrumentationKey string
param appInsightsConnectionString string
param defaultTags object

// Varabiles
var standardPlanMaxAdditionalSlots = 2
param environments array = [
  'dev'
  'qa'
]

resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: webAppPlanName // app serivce plan name
  location: location // Azure Region
  tags: defaultTags
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
    'WebAppUrl': 'https://${appService.name}-dev.azurewebsites.net/'
    type: 'SQLAzure'
  }
}

resource webAppPortalName_environments 'Microsoft.Web/sites/slots@2021-03-01' = [for item in environments: {
  name: '${webSiteName}/${item}'
  kind: 'app'
  location: location
  tags: {
    displayName: 'WebAppSlots'
  }
  properties: {
    serverFarmId: appServicePlan.id
  }
}]

// Location population tags
// https://docs.microsoft.com/en-us/azure/azure-monitor/app/monitor-web-app-availability

resource standardWebTestPageHome  'Microsoft.Insights/webtests@2020-10-05-preview' = {
  name: 'Prod - Page Home'
  location: location
  tags: {
    'hidden-link:/subscriptions/f5e66d29-1a7f-4ee3-822e-74f644d3e665/resourceGroups/${resourceGroupName}/providers/microsoft.insights/components/${appInsightsName}': 'Resource'
   }
  kind: 'ping'
  properties: {
    SyntheticMonitorId: appInsightsName
    Name: 'Prod - Page Home'
    Description: null
    Enabled: true
    Frequency: 300
    Timeout: 120 
    Kind: 'standard'
    RetryEnabled: true
    Locations: [
      {
        Id: 'us-va-ash-azr'  // East US
      }
      {
        Id: 'us-fl-mia-edge' // Central US
      }
      {
        Id: 'us-ca-sjc-azr' // West US
      }
      {
        Id: 'emea-au-syd-edge' // Austrailia East
      }
      {
        Id: 'apac-jp-kaw-edge' // Japan East
      }
    ]
    Configuration: null
    Request: {
      RequestUrl: 'https://${appService.name}.azurewebsites.net/'
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
  name: 'Prod - Page Nutritions'
  location: location
  tags: {
    'hidden-link:/subscriptions/f5e66d29-1a7f-4ee3-822e-74f644d3e665/resourceGroups/${resourceGroupName}/providers/microsoft.insights/components/${appInsightsName}': 'Resource'
  }
  kind: 'ping'
  properties: {
    SyntheticMonitorId: appInsightsName
    Name: 'Prod - Page Nutritions'
    Description: null
    Enabled: true
    Frequency: 300
    Timeout: 120 
    Kind: 'standard'
    RetryEnabled: true
    Locations: [
      {
        Id: 'us-va-ash-azr'  // East US
      }
      {
        Id: 'us-fl-mia-edge' // Central US
      }
      {
        Id: 'us-ca-sjc-azr' // West US
      }
      {
        Id: 'emea-au-syd-edge' // Austrailia East
      }
      {
        Id: 'apac-jp-kaw-edge' // Japan East
      }
    ]
    Configuration: null
    Request: {
      RequestUrl: 'https://${appService.name}.azurewebsites.net/Nutritions/'
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
  name: 'Prod - Page Exercises'
  location: location
  tags: {
     'hidden-link:/subscriptions/f5e66d29-1a7f-4ee3-822e-74f644d3e665/resourceGroups/${resourceGroupName}/providers/microsoft.insights/components/${appInsightsName}': 'Resource'
  }
  kind: 'ping'
  properties: {
    SyntheticMonitorId: appInsightsName
    Name: 'Prod - Page Exercises'
    Description: null
    Enabled: true
    Frequency: 300
    Timeout: 120 
    Kind: 'standard'
    RetryEnabled: true
    Locations: [
      {
        Id: 'us-va-ash-azr'  // East US
      }
      {
        Id: 'us-fl-mia-edge' // Central US
      }
      {
        Id: 'us-ca-sjc-azr' // West US
      }
      {
        Id: 'emea-au-syd-edge' // Austrailia East
      }
      {
        Id: 'apac-jp-kaw-edge' // Japan East
      }
    ]
    Configuration: null
    Request: {
      RequestUrl: 'https://${appService.name}.azurewebsites.net/Exercises/'
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

resource standardWebTestPageHomeDev  'Microsoft.Insights/webtests@2020-10-05-preview' = {
  name: 'Dev - Page Home'
  location: location
  tags: {
    'hidden-link:/subscriptions/f5e66d29-1a7f-4ee3-822e-74f644d3e665/resourceGroups/${resourceGroupName}/providers/microsoft.insights/components/${appInsightsName}': 'Resource'
  }
  kind: 'ping'
  properties: {
    SyntheticMonitorId: appInsightsName
    Name: 'Dev - Page Home'
    Description: null
    Enabled: true
    Frequency: 300
    Timeout: 120 
    Kind: 'standard'
    RetryEnabled: true
    Locations: [
      {
        Id: 'us-va-ash-azr'  // East US
      }
      {
        Id: 'us-fl-mia-edge' // Central US
      }
      {
        Id: 'us-ca-sjc-azr' // West US
      }
      {
        Id: 'emea-au-syd-edge' // Austrailia East
      }
      {
        Id: 'apac-jp-kaw-edge' // Japan East
      }
    ]
    Configuration: null
    Request: {
      RequestUrl: 'https://${appService.name}-dev.azurewebsites.net/'
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

resource standardWebTestPageNutritionsDev  'Microsoft.Insights/webtests@2020-10-05-preview' = {
  name: 'Dev - Page Nutritions'
  location: location
  tags: {
    'hidden-link:/subscriptions/f5e66d29-1a7f-4ee3-822e-74f644d3e665/resourceGroups/${resourceGroupName}/providers/microsoft.insights/components/${appInsightsName}': 'Resource'
  }
  kind: 'ping'
  properties: {
    SyntheticMonitorId: appInsightsName
    Name: 'Dev - Page Nutritions'
    Description: null
    Enabled: true
    Frequency: 300
    Timeout: 120 
    Kind: 'standard'
    RetryEnabled: true
    Locations: [
      {
        Id: 'us-va-ash-azr'  // East US
      }
      {
        Id: 'us-fl-mia-edge' // Central US
      }
      {
        Id: 'us-ca-sjc-azr' // West US
      }
      {
        Id: 'emea-au-syd-edge' // Austrailia East
      }
      {
        Id: 'apac-jp-kaw-edge' // Japan East
      }
    ]
    Configuration: null
    Request: {
      RequestUrl: 'https://${appService.name}-dev.azurewebsites.net/Nutritions/'
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

resource standardWebTestPageExercisesDev  'Microsoft.Insights/webtests@2020-10-05-preview' = {
  name: 'Dev - Page Exercises'
  location: location
  tags: {
    'hidden-link:/subscriptions/f5e66d29-1a7f-4ee3-822e-74f644d3e665/resourceGroups/${resourceGroupName}/providers/microsoft.insights/components/${appInsightsName}': 'Resource'
  }
  kind: 'ping'
  properties: {
    SyntheticMonitorId: appInsightsName
    Name: 'Dev - Page Exercises'
    Description: null
    Enabled: true
    Frequency: 300
    Timeout: 120 
    Kind: 'standard'
    RetryEnabled: true
    Locations: [
      {
        Id: 'us-va-ash-azr'  // East US
      }
      {
        Id: 'us-fl-mia-edge' // Central US
      }
      {
        Id: 'us-ca-sjc-azr' // West US
      }
      {
        Id: 'emea-au-syd-edge' // Austrailia East
      }
      {
        Id: 'apac-jp-kaw-edge' // Japan East
      }
    ]
    Configuration: null
    Request: {
      RequestUrl: 'https://${appService.name}-dev.azurewebsites.net/Exercises/'
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

//output webSiteName string = appService.name
//output webSiteURL string = appService.properties.defaultHostName

param configStoreName string
//param webSiteName string
param location string = resourceGroup().location
param defaultTags object

param contentType string = 'application/vnd.microsoft.appconfig.ff+json;charset=utf-8'

// App Configuration Settings
param FontNameKey string
param FontColorKey string
param FontSizeKey string
param FontNameValue string
param FontColorValue string
param FontSizeValue string

//
// TBD! These WILL be deleted...NOT needed - App Configuation
//
param ConfigName1 string = 'App:Settings:FontSize$lablegoeshere'
param ConfigValue1 string = '12'
param ConfigName2 string = 'App:Settings:FontColor$lablegoeshere'
param ConfigValue2 string = 'black'
param ConfigName3 string = 'App:Settings:BackgroundColor$lablegoeshere'
param ConfigValue3 string = 'white'
param ConfigName4 string = 'App:Settings:Sentinel$lablegoeshere'
param ConfigValue4 string = '1'
//
// TBD! These WILL be deleted...NOT needed - App Configuation
//

// Feature Flags
param FeatureFlagKey1 string = 'PrivacyBeta'
param FeatureFlagLabel1 string = ''
param FeatureFlagKey2 string = 'MetricsDashboard'
param FeatureFlagLabel2 string = ''
param FeatureFlagKey3 string = 'NutritionColor'
param FeatureFlagLabel3 string = ''
param FeatureFlagKey4 string = 'CognitiveServices'
param FeatureFlagLabel4 string = ''

var FeatureFlagValue1 = {
  id: FeatureFlagKey1
  description: 'Description for Privacy Beta.'
  enabled: true
}
var FeatureFlagValue2 = {
  id: FeatureFlagKey2
  description: 'Description for Metrics Dashboard.'
  enabled: true
}
var FeatureFlagValue3 = {
  id: FeatureFlagKey3
  description: 'Description for Nutrition Color.'
  enabled: false
}
var FeatureFlagValue4 = {
  id: FeatureFlagKey4
  description: 'Description for Cognitive Services.'
  enabled: false
}

// Create AppConfiguration configuration Store
// enableSoftDelete: false
resource config 'Microsoft.AppConfiguration/configurationStores@2022-05-01' = {
  name: configStoreName
  location: location
  tags: defaultTags
  properties: {
    enablePurgeProtection: false
    softDeleteRetentionInDays: 7
  }
  sku: {
    name: 'Standard'
  }
  identity: {
    type:'SystemAssigned'
  }
}

resource configStoreName_Values1 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  name: ConfigName1
  parent: config
  properties: {
    value: ConfigValue1
    contentType: 'application/json'
    tags: defaultTags
  }
}
resource configStoreName_Values2 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  name: ConfigName2
  parent: config
  properties: {
    value: ConfigValue2
    contentType: 'application/json'
    tags: defaultTags
  }
}
resource configStoreName_Values3 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  name: ConfigName3
  parent: config
  properties: {
    value: ConfigValue3
    contentType: 'application/json'
    tags: defaultTags
  }
}
resource configStoreName_Values4 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  name: ConfigName4
  parent: config
  properties: {
    value: ConfigValue4
    contentType: 'application/json'
    tags: defaultTags
  }
}

// Feature Flag 1
resource configStoreName_featureflags_1 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: config
  name: '.appconfig.featureflag~2F${FeatureFlagKey1}$${FeatureFlagLabel1}'
  properties: {
    value: string(FeatureFlagValue1)
    contentType: contentType
  }
}

// Feature Flag 2
resource configStoreName_featureflags_2 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: config
  name: '.appconfig.featureflag~2F${FeatureFlagKey2}$${FeatureFlagLabel2}'
  properties: {
    value: string(FeatureFlagValue2)
    contentType: contentType
  }
}

// Feature Flag 3
resource configStoreName_featureflags_3 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: config
  name: '.appconfig.featureflag~2F${FeatureFlagKey3}$${FeatureFlagLabel3}'
  properties: {
    value: string(FeatureFlagValue3)
    contentType: contentType
  }
}

// Feature Flag 4
resource configStoreName_featureflags_4 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: config
  name: '.appconfig.featureflag~2F${FeatureFlagKey4}$${FeatureFlagLabel4}'
  properties: {
    value: string(FeatureFlagValue4)
    contentType: contentType
  }
}

// Add App Configuration Settings
resource appConfigStoreName_FontNameKey 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: config
  name: FontNameKey
  properties: {
    value: FontNameValue
    contentType: 'application/json'
  }
}
resource appConfigStoreName_FontColorKey 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: config
  name: FontColorKey
  properties: {
    value: FontColorValue
    contentType: 'application/json'
  }
}
resource appConfigStoreName_FontSizeKey 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: config
  name: FontSizeKey
  properties: {
    value: FontSizeValue
    contentType: 'application/json'
  }
}

// Reference Existing resource
// resource existing_appService 'Microsoft.Web/sites@2022-03-01' existing = {
//   name: webSiteName
// }

// Add role assigment for Service Identity
// Azure built-in roles - https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
// App Configuration Data Reader	Allows read access to App Configuration data.	516239f1-63e1-4d78-a4de-a74fb236a071
//var AppConfigDataReaderRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '516239f1-63e1-4d78-a4de-a74fb236a071')

// Add role assignment to App Config Store
//  resource roleAssignmentForAppConfig 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
//   name: guid(config.id, AppConfigDataReaderRoleDefinitionId)
//   scope: config
//   properties: {
//     principalType: 'ServicePrincipal'
//     principalId: existing_appService.identity.principalId // reference(existing_appService.id, '2020-12-01', 'Full').identity.principalId
//     roleDefinitionId: AppConfigDataReaderRoleDefinitionId
//   }
// }

var configStoreConnectionString = listKeys(config.id, config.apiVersion).value[0].connectionString
output out_configStoreConnectionString string = configStoreConnectionString
output out_configStoreEndPoint string = config.properties.endpoint

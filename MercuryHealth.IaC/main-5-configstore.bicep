param configStoreName string
param location string = resourceGroup().location
param defaultTags object

// Specifies the names of the key-value resources. 
param ConfigkeyValueNames array = [
  'MercuryHealth:Settings:FontSize'
  'EMercuryHealth:Settings:Sentinel'
]

// Specifies the values of the key-value resources. It's optional
param ConfigkeyValueValues array = [
  '14'
  '1'
]

// param FeatureFlagkeyValueNames array [

// ]

// param FeatureFlagkeyValueKeys array [

// ]
// param FeatureFlagkeyValueNames array [

// ]

param featureFlagKey1 string = 'PrivacyBeta'
param featureFlagLabel1 string = 'Privacy Page'
var featureFlagValue1 = {
  id: featureFlagKey1
  description: 'Beta Privacy Page.'
  enabled: true
}

param featureFlagKey2 string = 'MetricsDashboard'
param featureFlagLabel2 string = 'Metrics Dashboard'
var featureFlagValue2 = {
  id: featureFlagKey2
  description: 'Metrics Dashboard.'
  enabled: false
}

param featureFlagKey3 string = 'CognitiveServices'
param featureFlagLabel3 string = 'Cognitive Services'
var featureFlagValue3 = {
  id: featureFlagKey3
  description: 'Cognitive Services.'
  enabled: false
}

param featureFlagKey4 string = 'CaptureNutritionColor'
param featureFlagLabel4 string = 'Capture Nutrition Color'
var featureFlagValue4 = {
  id: featureFlagKey4
  description: 'Capture Nutrition Color.'
  enabled: false
}

@description('Specifies the content type of the key-value resources. For feature flag, the value should be application/vnd.microsoft.appconfig.ff+json;charset=utf-8. For Key Value reference, the value should be application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8. Otherwise, it\'s optional.')
param contentType string = 'application/vnd.microsoft.appconfig.ff+json;charset=utf-8'

// AppConfiguration configuration Store
resource config 'Microsoft.AppConfiguration/configurationStores@2021-03-01-preview' = {
  name: configStoreName
  location: location
  tags: defaultTags
  sku: {
    name: 'Standard'
  }
}

resource configStoreName_keyValueNames 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = [for (item, i) in ConfigkeyValueNames: {
  name: '${config.name}/${item}'
  properties: {
    value: ConfigkeyValueValues[i]
    contentType: contentType
    tags: defaultTags
  }
}]

// Todo: Must add "key-value" pairs under Configuration Explorer
// MercuryHealth:Settings:FontSize = 14
// MercuryHealth:Settings:Sentinel = 1


// // AppConfiguration Key 1
// resource key1 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-03-01-preview' = {
//   name: '${config.name}/${keyValueNames[0]}'
//   properties: {
//     value: keyValueValues[0]
//     contentType: contentType
//   }
// }
// // AppConfiguration Key 2
// resource key2 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-03-01-preview' = {
//   name: '${config.name}/${keyValueNames[1]}'
//   properties: {
//     value: keyValueValues[1]
//     contentType: contentType
//   }
// }
// // AppConfiguration Key 3
// resource key3 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-03-01-preview' = {
//   name: '${config.name}/${keyValueNames[2]}'
//   properties: {
//     value: keyValueValues[2]
//     contentType: contentType
//   }
// }
// // AppConfiguration Key 4
// resource key4 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-03-01-preview' = {
//   name: '${config.name}/${keyValueNames[3]}'
//   properties: {
//     value: keyValueValues[3]
//     contentType: contentType
//   }
// }

// AppConfiguration Feature Flag Store
// resource configStoreName_appconfig_featureflags 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = [for (item, i) in FeatureFlagkeyValueNames: {
//   parent: config
//   name: '.appconfig.featureflag~2F${featureFlagKey1}$${featureFlagLabel1}'
//   properties: {
//     value: string(featureFlagValue1)
//     contentType: contentType
//   }
// }

// AppConfiguration Feature Flag Store
resource configStoreName_appconfig_featureflag_1 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  parent: config
  name: '.appconfig.featureflag~2F${featureFlagKey1}$${featureFlagLabel1}'
  properties: {
    value: string(featureFlagValue1)
    contentType: contentType
  }
}

// AppConfiguration Feature Flag Store
resource configStoreName_appconfig_featureflag_2 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  parent: config
  name: '.appconfig.featureflag~2F${featureFlagKey2}$${featureFlagLabel2}'
  properties: {
    value: string(featureFlagValue2)
    contentType: contentType
  }
}

// AppConfiguration Feature Flag Store
resource configStoreName_appconfig_featureflag_3 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  parent: config
  name: '.appconfig.featureflag~2F${featureFlagKey3}$${featureFlagLabel3}'
  properties: {
    value: string(featureFlagValue3)
    contentType: contentType
  }
}

// AppConfiguration Feature Flag Store
resource configStoreName_appconfig_featureflag_4 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  parent: config
  name: '.appconfig.featureflag~2F${featureFlagKey4}$${featureFlagLabel4}'
  properties: {
    value: string(featureFlagValue4)
    contentType: contentType
  }
}

//output configStoreEndpoint string = config.properties.endpoint
// disable-next-line outputs-should-not-contain-secrets // Does not contain a password

output configStoreConnection string = config.properties.endpoint
//output configStoreConnectionString string = listKeys(config.id, config.apiVersion).keys[0].value

param configStoreName string
param location string = resourceGroup().location
param defaultTags object

// Specifies the names of the key-value resources. 
// param keyValueNames array = [
//   'PrivacyBeta$myLabel'
//   'EnableMetricsDashboard$myLabel'
//   'EnableCognitiveServices$myLabel'
//   'CaptureNutritionColor$myLabel'
// ]

//

// // Specifies the values of the key-value resources. It's optional
// param keyValueValues array = [
//   'New Privacy Page with label'
//   'EnableMetricsDashboard with label'
//   'EnableCognitiveServices with label'
//   'CaptureNutritionColor with label'
// ]

param featureFlagKey1 string = 'PrivacyBeta'
param featureFlagLabel1 string = 'Privacy'
var featureFlagValue1 = {
  id: featureFlagKey1
  description: 'New Privacy Page.'
  enabled: true
}

param featureFlagKey2 string = 'EnableMetricsDashboard'
param featureFlagLabel2 string = 'Metrics'
var featureFlagValue2 = {
  id: featureFlagKey2
  description: 'EnableMetricsDashboard with label.'
  enabled: false
}

param featureFlagKey3 string = 'EnableCognitiveServices'
param featureFlagLabel3 string = 'Cognitive Services'
var featureFlagValue3 = {
  id: featureFlagKey3
  description: 'Enable Cognitive Services.'
  enabled: false
}

param featureFlagKey4 string = 'CaptureNutritionColor'
param featureFlagLabel4 string = 'Capture Nutrition Color'
var featureFlagValue4 = {
  id: featureFlagKey4
  description: 'Capture Nutrition Color.'
  enabled: false
}

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
output configStoreConnection string = listKeys(config.id, config.apiVersion).keys[0].value


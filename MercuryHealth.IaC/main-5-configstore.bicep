param configStoreName string
param location string = resourceGroup().location
param defaultTags object
//param configParent object

param contentType string = 'application/vnd.microsoft.appconfig.ff+json;charset=utf-8'

// // Specifies the names of the key-value resources. 
// param ConfigkeyValueNames array = [
//   'App:Settings:FontSize'
//   'App:Settings:FontColor'
//   'App:Settings:BackgroundColor'
//   'App:Settings:Sentinel'
// ]

// // Specifies the values of the key-value resources. #000=Black, #FFF=White
// param ConfigkeyKeyValues array = [
//   '12'
//   'black'
//   'white'
//   '1'
// ]

// Configuation
param ConfigName1 string = 'App:Settings:FontSize$lablegoeshere'
param ConfigValue1 string = '12'
param ConfigName2 string = 'App:Settings:FontColor$lablegoeshere'
param ConfigValue2 string = 'black'
param ConfigName3 string = 'App:Settings:BackgroundColor$lablegoeshere'
param ConfigValue3 string = 'white'
param ConfigName4 string = 'App:Settings:Sentinel$lablegoeshere'
param ConfigValue4 string = '1'

// Feature Flags
param FeatureFlagKey1 string = 'PrivacyBeta'
param FeatureFlagLabel1 string = ''
param FeatureFlagKey2 string = 'MetricsDashboard'
param FeatureFlagLabel2 string = ''
param FeatureFlagKey3 string = 'NutritionColor'
param FeatureFlagLabel3 string = ''

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
// var FeatureFlagValue4 = {
//   id: FeatureFlagKey4
//   description: 'Description for Metrics Dashboard 2.'
//   enabled: true
// }

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

// Loop through array and create Config Key Values
// resource configStoreName_keyValueNames 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = [for (item, i) in ConfigkeyValueNames: {
//   name: '${config.name}/${item}'
//   properties: {
//     value: ConfigkeyKeyValues[i]
//     contentType:
//     //contentType: contentType
//     tags: defaultTags
//   }
// }]

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
// resource configStoreName_appconfig_featureflags_1 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
//   parent: config
//   name: '.appconfig.featureflag~2F${FeatureFlagKey1}$${FeatureFlagLabel1}'
//   properties: {
//     value: string(FeatureFlagValue1)
//     contentType: contentType
//   }
// }
// // Feature Flag 2
// resource configStoreName_appconfig_featureflags_2 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
//   parent: config
//   name: '.appconfig.featureflag~2F${FeatureFlagKey2}$${FeatureFlagLabel2}'
//   properties: {
//     value: string(FeatureFlagValue2)
//     contentType: contentType
//   }
// }
// // Feature Flag 3
// resource configStoreName_appconfig_featureflags_3 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
//   parent: config
//   name: '.appconfig.featureflag~2F${FeatureFlagKey3}$${FeatureFlagLabel3}'
//   properties: {
//     value: string(FeatureFlagValue3)
//     contentType: contentType
//   }
// }

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

var configStoreConnectionString = listKeys(config.id, config.apiVersion).value[0].connectionString
output out_configStoreConnectionString string = configStoreConnectionString
output out_configStoreprincipalId string = config.identity.principalId

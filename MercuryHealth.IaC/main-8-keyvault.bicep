param location string = resourceGroup().location
param sqlserverName string
param sqlDBName string
param sqlAdministratorLogin string
param webSiteName string

@secure()
param sqlAdministratorLoginPassword string
param vaultName string
param tenant string = subscription().tenantId
param appServiceprincipalId string
//param appInsightsInstrumentationKey string
param sqlserverfullyQualifiedDomainName string

//@secure()
param configStoreConnection string

param accessPolicies array = [
  {
    tenantId: tenant
    objectId: appServiceprincipalId
    permissions: {
      keys: [
        'Get'
        'List'
      ]
      secrets: [
        'Get'
        'List'
      ]
    }
  }
]

//param keyName string = 'prodKey'
param secretName1 string
param secretValue1 string = configStoreConnection
param secretName2 string
param secretValue2 string = 'Server=tcp:${sqlserverfullyQualifiedDomainName},1433;Initial Catalog=${sqlDBName};Persist Security Info=False;User Id=${sqlAdministratorLogin}@${sqlserverName};Password=${sqlAdministratorLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

param networkAcls object = {
  ipRules: []
  virtualNetworkRules: []
}

resource keyvault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: vaultName
  location: location
  properties: {
    tenantId: tenant
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableSoftDelete: false
    accessPolicies: accessPolicies
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: false
    networkAcls: networkAcls
  }
}

// create secret
resource mySecret1 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: secretName1
  parent: keyvault
  properties: {
    contentType: 'text/plain'
    value: secretValue1
  }
}
// create secret
resource mySecret2 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: secretName2
  parent: keyvault
  properties: {
    contentType: 'text/plain'
    value: secretValue2
  }
}

// resource webSiteAppSettingsStrings 'Microsoft.Web/sites/config@2021-03-01' = {
//   name: '${webSiteName}/appsettings'
//   properties: {
//     'ConnectionStrings:MercuryHealthWebContextKV': '@Microsoft.KeyVault(VaultName=${vaultName};SecretName=${secretName2})'
//     'ConnectionStrings:AppConfigKV': '@Microsoft.KeyVault(VaultName=${vaultName};SecretName=${secretName1})'
//   }
// }
// create key
// resource mySecret1 'Microsoft.KeyVault/vaults/keys@2019-09-01' = {
//   name: '${keyvault.name}/${keyName}'
//   properties: {
//     kty: 'RSA' // key type
//     keyOps: [
//       // key operations
//       'encrypt'
//       'decrypt'
//     ]
//     keySize: 4096
//   }
// }

// // create secret
// resource secret3 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
//   name: '${keyvault.name}/${secretName3}'
//   properties: {
//     value: secretValue3
//   }
// }
// // create secret
// resource secret4 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
//   name: '${keyvault.name}/${secretName4}'
//   properties: {
//     value: secretValue4
//   }
// }
// // create secret
// resource secret5 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
//   name: '${keyvault.name}/${secretName5}'
//   properties: {
//     value: secretValue5
//   }
// }
// // create secret
// resource secret6 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
//   name: '${keyvault.name}/${secretName6}'
//   properties: {
//     value: secretValue6
//   }
// }
// // create secret
// resource secret7 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
//   name: '${keyvault.name}/${secretName7}'
//   properties: {
//     value: secretValue7
//   }
// }

output proxyKey object = keyvault
output keyvaultName string = keyvault.name
output out_secretName1 string = secretName1
output out_secretName2 string = secretName2

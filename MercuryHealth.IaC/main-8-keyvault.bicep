param location string = resourceGroup().location
param vaultName string
param tenant string = subscription().tenantId

// MercuryHealth_ServicePrincipal_Full
//param object string =  '61ad559f-a07a-4d8f-981b-c88e69216dd1' //subscription().subscriptionId

// param appServiceprincipalId string
// param secretName1 string
// param secretName2 string

// @secure()
// param configStoreConnection string
// @secure()
// param secretConnectionString string
// @secure()
// param secretAzureWebJobsStorage string

param accessPolicies array = []
// param accessPolicies array = [
//   {
//     tenantId: tenant
//     objectId: object
//     permissions: {
//       keys: [
//         'Get'
//         'List'
//       ]
//       secrets: [
//         'Get'
//         'List'
//       ]
//     }
//   }
// ]

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

// // create secret for Web App
// resource mySecret1 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
//   name: '${vaultName}/${secretName1}'
//   properties: {
//     contentType: 'text/plain'
//     value: configStoreConnection
//   }
// }
// // create secret for Web App
// resource mySecret2 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
//   name: '${vaultName}/${secretName2}'
//   properties: {
//     contentType: 'text/plain'
//     value: secretConnectionString
//   }
// }
// //create secret for Func App
// resource mySecret3 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
//   name: '${vaultName}/${secretName3}'
//   properties: {
//     contentType: 'text/plain'
//     value: secretAzureWebJobsStorage
//   }
// }
// // create secret for Func App
// resource mySecret4 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
//   name: '${vaultName}/${secretName4}'
//   properties: {
//     contentType: 'text/plain'
//     value: secretAzureWebJobsStorage
//   }
// }
// create secret
// resource mySecret1 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
//   name: secretName1
//   parent: keyvault
//   properties: {
//     contentType: 'text/plain'
//     value: secretValue1
//   }
// }
// create secret
// resource mySecret2 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
//   name: secretName2
//   parent: keyvault
//   properties: {
//     contentType: 'text/plain'
//     value: secretValue2
//   }
// }

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
// output out_secretName1 string = secretName1
// output out_secretName2 string = secretName2
// output out_secretValue2 string = secretValue2

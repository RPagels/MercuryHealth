param location string = resourceGroup().location
param sqlserverName string
param sqlDBName string
param sqlAdministratorLogin string
param sqlAdministratorLoginPassword string
param vaultName string
param sku string = 'Standard'
param tenant string = '72f988bf-86f1-41af-91ab-2d7cd011db47' // replace with your tenantId
param accessPolicies array = [
  {
    tenantId: tenant
    objectId: 'e8741716-82f1-48fb-86e2-4c5cdfce407d' // replace with your objectId
    permissions: {
      keys: [
        'Get'
        'List'
        'Update'
        'Create'
        'Import'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
      ]
      secrets: [
        'Get'
        'List'
        'Set'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
      ]
      certificates: [
        'Get'
        'List'
        'Update'
        'Create'
        'Import'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
        'ManageContacts'
        'ManageIssuers'
        'GetIssuers'
        'ListIssuers'
        'SetIssuers'
        'DeleteIssuers'
      ]
    }
  }
]

param enabledForDeployment bool = true
param enabledForTemplateDeployment bool = true
param enabledForDiskEncryption bool = true
param enableRbacAuthorization bool = false
param softDeleteRetentionInDays int = 90

param keyName string = 'prodKey'
param secretName1 string = 'AppConfigReadOnlyKey'
param secretValue1 string = 'Endpoint=https://mercuryhealth2019v3-appconfiguration.azconfig.io;Id=6O6i-l6-s0:Na+J3RiqRJqXCoq6SYV8;Secret=bZvOhXBtNwTIBw8ApU5NsuS8VvXKY9Q9wcS2ak+3qG4='
param secretName2 string = 'DBAdmin'
param secretValue2 string = 'AzureAdmin'
param secretName3 string = 'DBPassword'
param secretValue3 string = 'Password.1.!!@1'
param secretName4 string = 'DBConnectionString'
//param secretValue4 string = 'Server=tcp:mercuryhealth-server.database.windows.net,1433;Initial Catalog=mercuryhealth-database;Persist Security Info=False;User ID=AzureAdmin;Password=Password.1.!!@1;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
param secretValue4 string = 'Data Source=tcp:${sqlserverName},1433;Initial Catalog=${sqlDBName};User Id=${sqlAdministratorLogin}@${sqlserverName};Password=${sqlAdministratorLoginPassword};'

param secretName5 string = 'FunctionKeyQualityGate'
param secretValue5 string = 'bjMDi4HXhhXOq19ugz/YviYZqjk8xbIkCaho35cwad5IR5VDfLfRgA=='
param secretName6 string = 'AppInsightsAPIKey2'
param secretValue6 string = 'eb1d121x55kdyeogtx8477fb1p1mwd3pfe6j7y0c'
param secretName7 string = 'AppInsightsAppID'
param secretValue7 string = '447e0642-841c-4206-8dff-e25876f043e0'

param networkAcls object = {
  ipRules: []
  virtualNetworkRules: []
}

resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: vaultName
  location: location
  properties: {
    tenantId: tenant
    sku: {
      family: 'A'
      name: sku
    }
    accessPolicies: accessPolicies
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enableRbacAuthorization: enableRbacAuthorization
    networkAcls: networkAcls
  }
}

// create key
resource key 'Microsoft.KeyVault/vaults/keys@2019-09-01' = {
  name: '${keyvault.name}/${keyName}'
  properties: {
    kty: 'RSA' // key type
    keyOps: [
      // key operations
      'encrypt'
      'decrypt'
    ]
    keySize: 4096
  }
}

// create secret
resource secret1 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
  name: '${keyvault.name}/${secretName1}'
  properties: {
    value: secretValue1
  }
}

// create secret
resource secret2 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
  name: '${keyvault.name}/${secretName2}'
  properties: {
    value: secretValue2
  }
}
// create secret
resource secret3 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
  name: '${keyvault.name}/${secretName3}'
  properties: {
    value: secretValue3
  }
}
// create secret
resource secret4 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
  name: '${keyvault.name}/${secretName4}'
  properties: {
    value: secretValue4
  }
}
// create secret
resource secret5 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
  name: '${keyvault.name}/${secretName5}'
  properties: {
    value: secretValue5
  }
}
// create secret
resource secret6 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
  name: '${keyvault.name}/${secretName6}'
  properties: {
    value: secretValue6
  }
}
// create secret
resource secret7 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
  name: '${keyvault.name}/${secretName7}'
  properties: {
    value: secretValue7
  }
}

output proxyKey object = key

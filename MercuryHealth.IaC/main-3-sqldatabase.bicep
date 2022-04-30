param sqlserverName string
param sqlDBName string

// Azure SQL Credentials
@secure()
param sqlAdminLoginName string
@secure()
param sqlAdminLoginPassword string

param location string = resourceGroup().location
param defaultTags object

resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: sqlserverName
  location: location
  tags: defaultTags
  properties: {
    administratorLogin: sqlAdminLoginName
    administratorLoginPassword: sqlAdminLoginPassword
  }
}

// resource sqlDB 'Microsoft.Sql/servers/databases@2021-08-01-preview' = {
//   name: '${sqlServer.name}/${sqlDBName}'
//   location: location
//   tags: defaultTags
//   sku: {
//     name: 'Standard' //'Basic'
//     tier: 'Standard' //'Basic'
//   }
// }

resource sqlDB 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  name: '${sqlServer.name}/${sqlDBName}'
  location: location
  tags: defaultTags
  sku: {
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 1
  }
  properties: {
    requestedBackupStorageRedundancy: 'Local'
    zoneRedundant: false
  }
}

resource sqlserverName_AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2021-11-01-preview' = {
  name: '${sqlServer.name}/AllowAllWindowsAzureIps'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

output sqlserverfullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName

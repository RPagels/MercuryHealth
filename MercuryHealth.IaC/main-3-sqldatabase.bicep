param sqlserverName string
param sqlDBName string
param location string = resourceGroup().location
param administratorLogin string
param defaultTags object

@secure()
param administratorLoginPassword string

resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: sqlserverName
  location: location
  tags: defaultTags
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
}

resource sqlDB 'Microsoft.Sql/servers/databases@2021-08-01-preview' = {
  name: '${sqlServer.name}/${sqlDBName}'
  location: location
  tags: defaultTags
  sku: {
    name: 'Basic' //'Standard'
    tier: 'Basic' //'Standard'
  }
}

resource sqlserverName_AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2021-02-01-preview' = {
  name: '${sqlServer.name}/AllowAllWindowsAzureIps'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

output sqlserverfullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName

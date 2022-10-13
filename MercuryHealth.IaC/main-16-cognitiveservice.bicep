param cognitiveServiceName string
param location string
param defaultTags object

@allowed([
  'S0'
  'S1'
])
param sku string = 'S1'

resource cognitiveService 'Microsoft.CognitiveServices/accounts@2022-10-01' = {
  name: cognitiveServiceName
  tags: defaultTags
  location: location
  sku: {
    name: sku
  }
  kind: 'ComputerVision'
  identity: {
    type:'SystemAssigned'
  }
  properties: {
    customSubDomainName: 'mercuryhealth-${uniqueString(resourceGroup().id)}'
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    apiProperties: {
      statisticsEnabled: false
    }
    publicNetworkAccess: 'Enabled'
  }
}

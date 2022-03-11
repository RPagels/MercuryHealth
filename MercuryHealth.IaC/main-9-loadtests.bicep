param location string = resourceGroup().location
param loadTestsName string
param defaultTags object
//targetScope = 'subscription'
param principalId string = 'rpagels@microsoft.com'
var roleName = 'Load Test Contributor'

//param policyAssignmentName string = 'audit-vm-manageddisks'
//param policyDefinitionID string = '/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d'

resource loadtesting 'Microsoft.LoadTestService/loadTests@2021-12-01-preview' = {
    location: location
    name: loadTestsName
    tags: defaultTags
    properties: {
        description: 'Azure Load Testing Service'
    }

}

resource definition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' = {
  name: guid(roleName)
  properties: {
    roleName: roleName
    description: 'Azure Load Testing role'
    permissions: [
      {
        actions: [
          '*/write'
        ]
      }
    ]
    assignableScopes: [
      subscription().id
    ]
  }
}

resource assignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(roleName, principalId, subscription().subscriptionId)
  properties: {
    roleDefinitionId: definition.id
    principalId: principalId
  }
}

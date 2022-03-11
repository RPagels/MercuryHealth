param location string = resourceGroup().location
param loadTestsName string
param defaultTags object
//targetScope = 'subscription'
param principalId string = 'rpagels@microsoft.com'
//param roleName string = 'Load Test Contributor'

@description('Built-in role to assign')
param builtInRoleType string = 'Load Test Contributor'

var role = {
    Owner: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
    Contributor: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
    Reader: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7'
  }

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
  name: guid(role[builtInRoleType])
  properties: {
    roleName: role[builtInRoleType]
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
    name: guid(loadtesting.id, principalId, role[builtInRoleType])
    properties: {
      roleDefinitionId: definition.id
      principalId: principalId
    }
  }

// resource assignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
//   name: guid(roleName, principalId, subscription().subscriptionId)
//   properties: {
//     roleDefinitionId: definition.id
//     principalId: principalId
//   }
// }

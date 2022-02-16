param location string = resourceGroup().location
param policyAssignmentName string = 'audit-vm-manageddisks'
param policyDefinitionID string = '/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d'

// Enable HTTPS for App Services
resource assignment 'Microsoft.Authorization/policyAssignments@2021-09-01' = {
    name: policyAssignmentName
    location: location
    scope: subscriptionResourceId('Microsoft.Resources/resourceGroups', resourceGroup().name)
    properties: {
        policyDefinitionId: policyDefinitionID
    }
}

output assignmentId string = assignment.id

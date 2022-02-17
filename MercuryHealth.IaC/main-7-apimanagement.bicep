// The following will create an Azure APIM instance
//
// 
// DELETE https://management.azure.com/subscriptions/f5e66d29-1a7f-4ee3-822e-74f644d3e665/providers/Microsoft.ApiManagement/locations/eastus/deletedservices/apiService-ixveii3svqyh6?api-version=2020-06-01-preview
//

param location string = resourceGroup().location
param apiServiceName string
param defaultTags object

@minLength(1)
param publisherEmail string = 'rpagels@microsoft.com'

@minLength(1)
param publisherName string = 'Randy Pagels'

@allowed([
  'Consumption'
  'Developer'
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Consumption'
param skuCount int = 0 // Must be Zero for Consumption

// resource apiManagement 'Microsoft.ApiManagement/service@2021-08-01' = {
//   name: apiServiceName
//   location: location
//   tags: defaultTags
//   sku: {
//     name: sku
//     capacity: skuCount
//   }
//   properties: {
//     publisherName: publisherName
//     publisherEmail: publisherEmail
//   }
//   identity: {
//     type: 'SystemAssigned'
//   }
// }

resource apiManagement 'Microsoft.ApiManagement/service@2020-12-01' = {
  name: apiServiceName
  location: location
  tags: defaultTags
  sku: {
    name: sku
    capacity: skuCount
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
  identity: {
    type: 'SystemAssigned'
  }
}

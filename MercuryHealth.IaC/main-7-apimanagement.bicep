// The following will create an Azure APIM instance

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

resource apiManagement 'Microsoft.ApiManagement/service@2021-08-01' = {
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

resource petStoreApiExample 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
  name: '${apiManagement.name}/PetStoreSwaggerImportExample'
  properties: {
    format: 'swagger-link-json'
    value: 'http://petstore.swagger.io/v2/swagger.json'
    path: 'examplepetstore'
  }
}

// resource MercuryHealthApiExample 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
//   name: '${apiManagement.name}/MercuryHealthSwaggerImportExample'
//   properties: {
//     format:'openapi+json'
//     value: 'https://app-fq3ruuhxgjony.azurewebsites.net/swagger/v1/swagger.json'
//     path: 'MercuryHealthApiExample'
//   }
// }

// Copy APIs from "Dev" instance
resource MercuryHealthApiExample 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
  name: '${apiManagement.name}/MercuryHealthSwaggerImportExample'
  properties: {
    format: 'swagger-json' //'openapi-link' //'openapi+json-link' //openapi+json' //'openapi'
    value: 'https://app-fq3ruuhxgjony.azurewebsites.net/swagger/v1/swagger.json'
    path: 'MercuryHealthApiExample'
  }
}

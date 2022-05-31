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

resource apiManagement 'Microsoft.ApiManagement/service@2021-12-01-preview' = {
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

param swaggerType string = 'yaml-v3'

// This url needs to be reachable for APIM
param urlToSwagger string = 'https://app-fq3ruuhxgjony.azurewebsites.net/swagger/v1/swagger.json'
// There can be only one api without path
param apiPath string = ''
param name string = 'MercuryHealthSwaggerImportExample'

var format = ((swaggerType == 'yaml-v3')  ? 'openapi-link' : 'openapi+json-link')

// Create APIs from "Dev" instance
resource api 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
  name: '${apiManagement.name}/${name}'
  properties: {
    format: format
    value: urlToSwagger
    path: apiPath
    displayName: 'MercuryHealthSwaggerImportExample'
    // apiVersion: apiVersion
    // apiVersionSetId: apiVersionSet.id
  }
}

// Copy APIs from "Dev" instance
//resource MercuryHealthApiExample 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
//  name: '${apiManagement.name}/MercuryHealthSwaggerImportExample'
//  properties: {
//    format: 'openapi-link'
//    value: 'https://app-fq3ruuhxgjony.azurewebsites.net/swagger/v1/swagger.json'
//    path: ''
//    displayName: 'Mercury Health TEST'
//  }
//}

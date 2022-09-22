// The following will create an Azure APIM instance

param location string = resourceGroup().location
param apiServiceName string
param appInsightsName string
param applicationInsightsID string
param appInsightsInstrumentationKey string
param webSiteName string

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
param sku string = 'Developer' // 'Developer' or 'Consumption'
param skuCount int = 1  // Developr = 1, Consumption = 0

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

// Create the Subscription for Developers
resource apiManagementSubscription 'Microsoft.ApiManagement/service/subscriptions@2021-12-01-preview' = {
  parent: apiManagement
  name: 'developers'
  properties: {
    scope: '/apis' // Subscription applies to all APIs
    displayName: 'Mercury Health - Developers'
    state: 'active'
  }
}

// Create the Product
resource apiManagementProduct 'Microsoft.ApiManagement/service/products@2021-12-01-preview' = {
  parent: apiManagement
  name: 'development'
  properties: {
    approvalRequired: false
    state: 'published'
    subscriptionRequired: true
    subscriptionsLimit: 1
    description: 'Product used for Mercury Health Development Teams'
    displayName: 'Mercury Health - Developers'
     terms: 'These are the terms of use ...'
  }
}

// Create the Product Policies
resource apiManagementProductPolicies 'Microsoft.ApiManagement/service/products/policies@2021-12-01-preview' = {
  name: 'policy'
  parent: apiManagementProduct
  properties: {
    value: '<policies>\r\n  <inbound>\r\n    <rate-limit calls="5" renewal-period="60" />\r\n    <quota calls="100" renewal-period="604800" />\r\n    <base />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
}

// Create the API Logger for Application Insights
resource appInsightsAPILogger 'Microsoft.ApiManagement/service/loggers@2021-12-01-preview' = {
  parent: apiManagement
  name: appInsightsName // 'MercuryHealth-applicationinsights'
  properties: {
    loggerType: 'applicationInsights'
    description: 'Mercury Health Application Insights instance.'
    resourceId: applicationInsightsID
    credentials: {
      instrumentationKey: appInsightsInstrumentationKey
    }
  }
}

//
// Mercury Health Swagger
//
// @allowed([
//   'yaml-v3' //uses 'openapi-link' format
//   'json-v3' //uses 'openapi+json-link' format
// ])
// param swaggerType string = 'yaml-v3'

// // This url needs to be reachable for APIM
// param urlToSwagger string = 'https://raw.githubusercontent.com/RPagels/MercuryHealth/master/MercuryHealth.IaC/MercuryHealth.openapi.yaml'
// //param urlToSwagger string = './MercuryHealth.IaC/MercuryHealth.openapi.yaml'
// param apiPath string = '' // There can be only one api without path
// param name string = 'mercury-health'
// var format = ((swaggerType == 'yaml-v3')  ? 'openapi-link' : 'openapi+json-link')

// // Create APIs from template
// resource apiManagementMercuryHealthImport 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
//   name: '${apiManagement.name}/${name}'
//   properties: {
//     format: format
//     value: urlToSwagger // OR value: loadTextContent('./MercuryHealth.swagger.json')
//     path: apiPath
//     displayName: 'Mercury Health'
//     serviceUrl: 'https://${webSiteName}.azurewebsites.net/'
//   }
// }
//
// Mercury Health Swagger
//

////////////////////////////
// Create API Definition
resource apiManagementMercuryHealthAPIs 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
  parent: apiManagement
  name: 'mercury-health'
  properties: {
    displayName: 'Mercury Health'
    description: 'Description for Mercury Health'
    serviceUrl: 'https://${webSiteName}.azurewebsites.net/'
    path: 'examplepath'
    protocols: [
      'https'
    ]
  }
}
///////////////////////////////////////////

// Create the Product for API
resource apiManagementProductApi 'Microsoft.ApiManagement/service/products/apis@2021-12-01-preview' = {
  parent: apiManagementProduct
  name: 'mercury-health'
  dependsOn: [
    apiManagementMercuryHealthAPIs
  ]
}

// Create reference to existing API
// resource apiManagementMercuryHealthApis 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' existing = {
//   name: 'mercury-health'
//   parent: apiManagement
// }

// Configure logging for the API.
resource appInsightsAPIMercuryHealthdiagnostics 'Microsoft.ApiManagement/service/apis/diagnostics@2021-12-01-preview' = {
  parent: apiManagementMercuryHealthAPIs
  name: 'applicationinsights'
  properties: {
    loggerId: appInsightsAPILogger.id
    alwaysLog: 'allErrors'
    logClientIp: true
    sampling: {
      samplingType: 'fixed'
      percentage: 100
    }
    verbosity: 'information'
    httpCorrelationProtocol: 'Legacy'
    frontend: {
      request: {
        headers: []
        body: {
          bytes: 0
        }
      }
      response: {
        headers: []
        body: {
          bytes: 0
        }
      }
    }
    backend: {
      request: {
        headers: []
        body: {
          bytes: 0
        }
      }
      response: {
        headers: []
        body: {
          bytes: 0
        }
      }
    }
  }
}

resource apiManagementServiceName_exampleUser1 'Microsoft.ApiManagement/service/users@2021-12-01-preview' = {
  parent: apiManagement
  name: 'exampleUser1'
  properties: {
    firstName: 'ExampleFirstName1'
    lastName: 'ExampleLastName1'
    email: 'ExampleFirst1@example.com'
    state: 'active'
    note: 'note for example user 1'
  }
}

//////////////////////////////////////////////

// resource apiManagementServiceName_exampleApi 'Microsoft.ApiManagement/service/apis@2017-03-01' = {
//   parent: apiManagement
//   name: 'exampleApi'
//   properties: {
//     displayName: 'Example API Name'
//     description: 'Description for example API'
//     serviceUrl: 'https://example.net'
//     path: 'exampleapipath'
//     protocols: [
//       'https'
//     ]
//   }
// }

resource apiManagementServiceName_exampleApiWithPolicy 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
  parent: apiManagement
  name: 'exampleApiWithPolicy'
  properties: {
    displayName: 'Example API Name with Policy'
    description: 'Description for example API with policy'
    serviceUrl: 'https://exampleapiwithpolicy.net'
    path: 'exampleapiwithpolicypath'
    protocols: [
      'https'
    ]
  }
}
// Evaluates to /api/Nutritions/{id}
var urlTemplateSuffix2 = 'IdwithCurlyBracesGoesHere' // '\'{id\'}'
param urlTemplateSuffixArray array = [
  '"{'
  'id'
  '}"'
]
var urlTemplateSuffix = concat(urlTemplateSuffixArray)

resource apiManagementServiceName_exampleApi_exampleOperationsDELETE 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  parent: apiManagementServiceName_exampleApiWithPolicy
  name: 'exampleOperationsDELETE'
  properties: {
    displayName: 'Delete a Nutrition item'
    method: 'DELETE'
    urlTemplate: '/api/Nutritions/${urlTemplateSuffix2}'
    description: 'A demonstration of a DELETE call'
  }
}
// Create GET-many operation
resource apiManagementServiceName_exampleApi_exampleOperationsGETMany 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  parent: apiManagementServiceName_exampleApiWithPolicy
  name: 'exampleOperationsGET1'
  properties: {
    displayName: 'Get all Nutrition items'
    method: 'GET'
    urlTemplate: '/api/Nutritions'
    description: 'A demonstration of a GET a call'
  }
}
// Create GET-single operation
resource apiManagementServiceName_exampleApi_exampleOperationsGET2 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  parent: apiManagementServiceName_exampleApiWithPolicy
  name: 'exampleOperationsGET2'
  properties: {
    displayName: 'Get all Nutrition items'
    method: 'GET'
    urlTemplate: '/api/Nutritions/id'
    description: 'A demonstration of a GET one call'
  }
}
// Apply policy for GET-many operations
resource apiManagementServiceName_exampleApi_exampleOperationsGET_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2021-12-01-preview' = {
  parent: apiManagementServiceName_exampleApi_exampleOperationsGETMany
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: loadTextContent('./operationGETPolicy.xml')
  }
}
// Apply policy for DELETE operations
resource apiManagementServiceName_exampleApi_exampleOperationsDELETE_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2021-12-01-preview' = {
  parent: apiManagementServiceName_exampleApi_exampleOperationsDELETE
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: loadTextContent('./operationDELETEPolicy.xml')
  }
}
// Apply policy for all API
resource apiPolicy 'Microsoft.ApiManagement/service/apis/policies@2021-12-01-preview' = {
  parent: apiManagementServiceName_exampleApiWithPolicy
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: loadTextContent('./operationAPIPolicy.xml')
  }
}

resource apiManagementServiceName_exampleProduct 'Microsoft.ApiManagement/service/products@2021-12-01-preview' = {
  parent: apiManagement
  name: 'exampleProduct'
  properties: {
    displayName: 'Example Product Name'
    description: 'Description for example product'
    terms: 'Terms for example product'
    subscriptionRequired: true
    approvalRequired: false
    subscriptionsLimit: 1
    state: 'published'
  }
}

// resource apiManagementServiceName_exampleProduct_exampleApi 'Microsoft.ApiManagement/service/products/apis@2021-12-01-preview' = {
//   parent: apiManagementServiceName_exampleProduct
//   name: 'exampleApi'
//   dependsOn: [
//     apiManagementServiceName_exampleApi
//   ]
// }
resource apiManagementServiceName_exampleProduct_policy 'Microsoft.ApiManagement/service/products/policies@2021-12-01-preview' = {
  parent: apiManagementServiceName_exampleProduct
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: loadTextContent('./operationPRODUCTPolicy.xml')
  }
}

resource apiManagementServiceName_exampleproperties 'Microsoft.ApiManagement/service/properties@2019-01-01' = {
  parent: apiManagement
  name: 'exampleproperties'
  properties: {
    displayName: 'propertyExampleName'
    value: 'propertyExampleValue'
    tags: [
      'exampleTag'
    ]
  }
}

// resource apiManagementServiceName_examplesubscription1 'Microsoft.ApiManagement/service/subscriptions@2021-12-01-preview' = {
//   parent: apiManagement
//   name: 'examplesubscription1'
//   properties: {
//     productId: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ApiManagement/service/exampleServiceName/products/exampleProduct'
//     userId: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ApiManagement/service/exampleServiceName/users/exampleUser1'
//   }
//   dependsOn: [
//     apiManagementServiceName_exampleProduct
//     apiManagementServiceName_exampleUser1
//   ]
// }

//////////////////////////////////////////////

var ApimSubscriptionKeyString = apiManagementSubscription.listSecrets().primaryKey

output out_ApimSubscriptionKeyString string = ApimSubscriptionKeyString
output out_ApimWebServiceURL string = apiManagement.properties.gatewayUrl

//////////////////////////////////////////////
//////////////////////////////////////////////
//////////////////////////////////////////////

// resource petStoreApiExample 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
//   name: '${apiManagement.name}/PetStoreSwaggerImportExample'
//   properties: {
//     format: 'swagger-link-json'
//     value: 'http://petstore.swagger.io/v2/swagger.json'
//     path: 'examplepetstore'
//   }
// }

// param swaggerType string = 'yaml-v3'

// // This url needs to be reachable for APIM
// param urlToSwagger string = 'https://app-fq3ruuhxgjony.azurewebsites.net/swagger/v1/swagger.json'
// // There can be only one api without path
// param apiPath string = ''
// param name string = 'MercuryHealthSwaggerImportExample'

// var format = ((swaggerType == 'yaml-v3')  ? 'openapi-link' : 'openapi+json-link')

// // Create APIs from "Dev" instance
// resource api 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
//   name: '${apiManagement.name}/${name}'
//   properties: {
//     format: format
//     value: urlToSwagger
//     path: apiPath
//     displayName: 'MercuryHealthSwaggerImportExample'
//     // apiVersion: apiVersion
//     // apiVersionSetId: apiVersionSet.id
//   }
// }

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

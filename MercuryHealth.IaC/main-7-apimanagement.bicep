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

// 'Developer' or 'Consumption'
@allowed([
  'Consumption'
  'Developer'
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Developer'

// Developer = 1, Consumption = 0
param skuCount int = 1

///////////////////////////////////////////
// Create API Management Service Definition
///////////////////////////////////////////
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

///////////////////////////////////////////
// Create the Subscription for Developers
///////////////////////////////////////////
resource apiManagementSubscription 'Microsoft.ApiManagement/service/subscriptions@2021-12-01-preview' = {
  parent: apiManagement
  name: 'Developers'
  properties: {
    scope: '/apis'
    displayName: 'Mercury Health Developers'
    state: 'active'
  }
}

///////////////////////////////////////////
// Create a Product
///////////////////////////////////////////
resource apiManagementProduct 'Microsoft.ApiManagement/service/products@2021-12-01-preview' = {
  parent: apiManagement
  name: 'Development'
  properties: {
    approvalRequired: false
    state: 'published'
    subscriptionRequired: true
    subscriptionsLimit: 1
    description: 'Product used for Mercury Health Development Teams'
    displayName: 'Mercury Health Developers'
     terms: 'These are the terms of use ... .etc'
  }
}

///////////////////////////////////////////
// Create Policy for Product Definitions 
///////////////////////////////////////////
resource apiManagementProductPolicies 'Microsoft.ApiManagement/service/products/policies@2021-12-01-preview' = {
  parent: apiManagementProduct
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: loadTextContent('./policy_Products.xml')
  }
}

///////////////////////////////////////////
// Create API Service Definition
///////////////////////////////////////////
resource apiManagementMercuryHealthAPIs 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
  parent: apiManagement
  name: 'mercury-health'
  properties: {
    displayName: 'Mercury Health'
    description: 'A sample API that uses a Mercury Health as an example to demonstrate features.'
    serviceUrl: 'https://${webSiteName}.azurewebsites.net/'
    path: ''
    subscriptionRequired: true
    protocols: [
      'https'
    ]
  }
}

///////////////////////////////////////////
// Create Policy for API Definitions 
///////////////////////////////////////////
resource apiPolicy 'Microsoft.ApiManagement/service/apis/policies@2021-12-01-preview' = {
  parent: apiManagementMercuryHealthAPIs
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: loadTextContent('./policy_API.xml')
  }
}

///////////////////////////////////////////
// Create the API for Product
///////////////////////////////////////////
resource apiManagementProductApi 'Microsoft.ApiManagement/service/products/apis@2021-12-01-preview' = {
  parent: apiManagementProduct
  name: 'mercury-health'
  dependsOn: [
    apiManagementMercuryHealthAPIs
  ]
}

///////////////////////////////////////////
// Create the API Logger for Application Insights
///////////////////////////////////////////
resource appInsightsAPILogger 'Microsoft.ApiManagement/service/loggers@2021-12-01-preview' = {
  parent: apiManagement
  name: appInsightsName
  properties: {
    loggerType: 'applicationInsights'
    description: 'Mercury Health Application Insights instance.'
    resourceId: applicationInsightsID
    credentials: {
      instrumentationKey: appInsightsInstrumentationKey
    }
  }
}

///////////////////////////////////////////
// Configure logging for the API Service
///////////////////////////////////////////
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

///////////////////////////////////////////
// Create User Account for the API Service
///////////////////////////////////////////
// resource apiManagementServiceName_User1 'Microsoft.ApiManagement/service/users@2021-12-01-preview' = {
//   parent: apiManagement
//   name: 'User1'
//   properties: {
//     firstName: 'FirstName'
//     lastName: 'LastName'
//     email: 'FirstName.LastName@example.com'
//     state: 'active'
//     note: 'Note for example user 1'
//   }
// }

///////////////////////////////////////////
///////////////////////////////////////////
// Create ALL Operation Definitions 
///////////////////////////////////////////
///////////////////////////////////////////

// Create Operation Definitions - Access Logs
resource apiManagementMercuryHealthAPIs_AccessLogsGETMany 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  parent: apiManagementMercuryHealthAPIs
  name: 'AccessLogsGETMany'
  properties: {
    displayName: 'Get all Access Logs items'
    method: 'GET'
    urlTemplate: '/api/AccessLogs'
    description: 'A demonstration of a GET  call'
  }
}
// Create Operation Definitions - Access Logs
resource apiManagementMercuryHealthAPIs_AccessLogsGETSingle 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  parent: apiManagementMercuryHealthAPIs
  name: 'AccessLogsGETSingle'
  properties: {
    displayName: 'Get a Access Logs item'
    method: 'GET'
    urlTemplate: '/api/AccessLogs/{id}'
    description: 'A demonstration of a GET single call'
    templateParameters: [
      {
        name: 'id'
        required: true
        type: 'string'
      }
    ]
  }
}

// Create Operation Definitions - Nutritions
resource apiManagementMercuryHealthAPIs_NutritionsGETMany 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  parent: apiManagementMercuryHealthAPIs
  name: 'NutritionsGETMany'
  properties: {
    displayName: 'Get all Nutrition items'
    method: 'GET'
    urlTemplate: '/api/Nutritions'
    description: 'A demonstration of a GET call'
  }
}
// Create Operation Definitions - Nutritions
resource apiManagementMercuryHealthAPIs_NutritionsGETSingle 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  parent: apiManagementMercuryHealthAPIs
  name: 'NutritionsGETSingle'
  properties: {
    displayName: 'Get a Nutrition item'
    method: 'GET'
    urlTemplate: '/api/Nutritions/{id}'
    description: 'A demonstration of a GET single call'
    templateParameters: [
      {
        name: 'id'
        required: true
        type: 'string'
      }
    ]
  }
}

// Create Operation Definitions - Nutritions
resource apiManagementMercuryHealthAPIs_NutritionsDELETESingle 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  parent: apiManagementMercuryHealthAPIs
  name: 'NutritionsDELETESingle'
  properties: {
    displayName: 'Delete a Nutrition item'
    method: 'DELETE'
    urlTemplate: '/api/Nutritions/{id}'
    description: 'A demonstration of a DELETE call'
    templateParameters: [
      {
        name: 'id'
        required: true
        type: 'string'
      }
    ]
  }
}
// Create Operation Definitions - Nutritions
resource apiManagementMercuryHealthAPIs_NutritionsPUTSingle 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  parent: apiManagementMercuryHealthAPIs
  name: 'NutritionsPUTSingle'
  properties: {
    displayName: 'Put a Nutrition item'
    method: 'PUT'
    urlTemplate: '/api/Nutritions/{id}'
    description: 'A demonstration of a PUT call'
    templateParameters: [
      {
        name: 'id'
        required: true
        type: 'string'
      }
    ]
  }
}
// Create Operation Definitions - Nutritions
resource apiManagementMercuryHealthAPIs_NutritionsPOSTSingle 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  parent: apiManagementMercuryHealthAPIs
  name: 'NutritionsPOSTSingle'
  properties: {
    displayName: 'Post a Nutrition item'
    method: 'POST'
    urlTemplate: '/api/Nutritions'
    description: 'A demonstration of a POST call'
  }
}

// Create Operation Definitions - Exercises
resource apiManagementMercuryHealthAPIs_ExercisesGETMany 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  parent: apiManagementMercuryHealthAPIs
  name: 'ExercisesGETMany'
  properties: {
    displayName: 'Get all Exercises items'
    method: 'GET'
    urlTemplate: '/api/Exercises'
    description: 'A demonstration of a GET a call'
  }
}
// Create Operation Definitions - Exercises
resource apiManagementMercuryHealthAPIs_ExercisesGETSingle 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  parent: apiManagementMercuryHealthAPIs
  name: 'ExercisesGETSingle'
  properties: {
    displayName: 'Get a Exercises item'
    method: 'GET'
    urlTemplate: '/api/Exercises/{id}'
    description: 'A demonstration of a GET single call'
    templateParameters: [
      {
        name: 'id'
        required: true
        type: 'string'
      }
    ]
  }
}

// Create Operation Definitions - Exercises
resource apiManagementMercuryHealthAPIs_ExercisesDELETESingle 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  parent: apiManagementMercuryHealthAPIs
  name: 'ExercisesDELETESingle'
  properties: {
    displayName: 'Delete a Exercises item'
    method: 'DELETE'
    urlTemplate: '/api/Exercises/{id}'
    description: 'A demonstration of a DELETE call'
    templateParameters: [
      {
        name: 'id'
        required: true
        type: 'string'
      }
    ]
  }
}
// Create Operation Definitions - Exercises
resource apiManagementMercuryHealthAPIs_ExercisesPUTSingle 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  parent: apiManagementMercuryHealthAPIs
  name: 'NExercisesPUTSingle'
  properties: {
    displayName: 'Put a Exercises item'
    method: 'PUT'
    urlTemplate: '/api/Exercises/{id}'
    description: 'A demonstration of a PUT call'
    templateParameters: [
      {
        name: 'id'
        required: true
        type: 'string'
      }
    ]
  }
}
// Create Operation Definitions - Exercises
resource apiManagementMercuryHealthAPIs_ExercisesPOSTSingle 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  parent: apiManagementMercuryHealthAPIs
  name: 'ExercisesPOSTSingle'
  properties: {
    displayName: 'Post a Exercises item'
    method: 'POST'
    urlTemplate: '/api/Exercises'
    description: 'A demonstration of a POST call'
  }
}

///////////////////////////////////////////
// Create Policy for Operation Definitions 
///////////////////////////////////////////

// Apply policy GET operations - Nutritions
resource apiManagementMercuryHealthAPIs_NutritionsGETMany_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2021-12-01-preview' = {
  parent: apiManagementMercuryHealthAPIs_NutritionsGETMany
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: loadTextContent('./policy_NutritionsGETMany.xml')
  }
}
// Apply policy GET operations - Exercises
resource apiManagementMercuryHealthAPIs_ExercisesGETMany_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2021-12-01-preview' = {
  parent: apiManagementMercuryHealthAPIs_ExercisesGETMany
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: loadTextContent('./policy_ExercisesGETMany.xml')
  }
}
// Apply policy for DELETE operations - Nutritions
resource apiManagementMercuryHealthAPIs_NutritionsDELETE_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2021-12-01-preview' = {
  parent: apiManagementMercuryHealthAPIs_NutritionsDELETESingle
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: loadTextContent('./policy_NutritionsDELETE.xml')
  }
}
// Apply policy for DELETE operations - Exercises
resource apiManagementMercuryHealthAPIs_ExercisesDELETE_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2021-12-01-preview' = {
  parent: apiManagementMercuryHealthAPIs_ExercisesDELETESingle
  name: 'policy'
  properties: {
    format: 'rawxml'
    value: loadTextContent('./policy_ExercisesDELETE.xml')
  }
}

//////////////////////////////////////////////
// Add Pet Store APIs for example
//////////////////////////////////////////////
resource petStoreApiExample 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
  name: '${apiManagement.name}/PetStoreSwaggerImportExample'
  properties: {
    format: 'swagger-link-json'
    value: 'http://petstore.swagger.io/v2/swagger.json'
    path: 'examplepetstore'
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

var ApimSubscriptionKeyString = apiManagementSubscription.listSecrets().primaryKey

output out_ApimSubscriptionKeyString string = ApimSubscriptionKeyString
output out_ApimWebServiceURL string = apiManagement.properties.gatewayUrl

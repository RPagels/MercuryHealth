param location string = resourceGroup().location
//param webSiteName string
param appInsightsName string
param appInsightsAlertName string
param defaultTags object
//param releaseAnnotationGuid string = newGuid()
//param releaseAnnotationDateStamp string = utcNow('yyyy-MM-ddTHH:mm:ss')

// Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: defaultTags
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: appInsightsAlertName
  location: 'global'
  properties: {
    description: 'Response time alert'
    severity: 0
    enabled: true
    scopes: [
      applicationInsights.id
      // ERROR during Deployment
      // "Property id 'b7e034a7-df34-4fef-a6ea-28136655e0a7' at path 'properties.scopes[0]' is invalid. Expect fully qualified resource Id that start with '/subscriptions/***subscriptionId***' or '/providers/***resourceProviderNamespace***/'

    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: '1st criterion'
          metricName: 'requests/duration'
          operator: 'GreaterThan'
          threshold: 100
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    actions: [
      {
        actionGroupId: emailActionGroup.id
      }
    ]
  }
}

resource emailActionGroup 'microsoft.insights/actionGroups@2019-06-01' = {
  name: 'emailActionGroup'
  location: 'global'
  properties: {
    groupShortName: 'Randy Pagels'
    enabled: true
    emailReceivers: [
      {
        name: 'Randy Pagels'
        emailAddress: 'rpagels@microsoft.com'
        useCommonAlertSchema: true
      }
    ]
  }
}

output out_appInsightsInstrumentationKey string = applicationInsights.properties.InstrumentationKey
output out_appInsightsConnectionString string = applicationInsights.properties.ConnectionString

output out_appInsightsApplicationId string = applicationInsights.properties.ApplicationId
output out_appInsightsAPIApplicationId string = applicationInsights.properties.AppId
//output out_applicationInsightsApiAppId string = applicationInsights.properties.AppId
//output out_releaseAnnotationId string = releaseAnnotationGuid

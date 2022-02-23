param location string = resourceGroup().location
//param webSiteName string
param appInsightsName string
param appInsightsAlertName string
param defaultTags object

// Application Insights
resource AppInsights_webSiteName 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: defaultTags
  // tags: {
  //   'hidden-link:${webSiteName}': 'Resource'
  //   displayName: 'AppInsightsComponent'
  // }
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
      AppInsights_webSiteName.properties.InstrumentationKey
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
          threshold: 60
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

output appInsightsInstrumentationKey string = AppInsights_webSiteName.properties.InstrumentationKey
output appInsightsConnectionString string = AppInsights_webSiteName.properties.ConnectionString

param location string = resourceGroup().location
//param webSiteName string
param appInsightsName string
param defaultTags object

//param appInsights_webTestUrl string = 'http//:www.bing.com'
//param webTestLocation string
//param componentName string = 'componentName'
// param testName string = 'testName'
// param testEndpoint string
// param numLocationsToAlertOn int = 5
// param alertDescription string = 'alertDescription'

// Specifies the names of the key-value resources. 
//@description('The list of web tests to run. See the README for the schema of test descriptor object.')
//param tests array = [
//  webSiteURL
//]

// param testLocations array = [
//   'us-va-ash-azr'
//   'us-va-ash-azr'
// ]

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

//  resource testName_resource 'Microsoft.Insights/webtests@2015-05-01' = {
//   name: testName
//   location: location
//   // tags: {
//   //   'hidden-link:${resourceId('microsoft.insights/components', componentName)}': 'Resource'
//   // }
//   properties: {
//     SyntheticMonitorId: testName
//     Name: testName
//     Enabled: true
//     Frequency: 300
//     Timeout: 120
//     Kind: 'ping'
//     RetryEnabled: false
//     Locations: testLocations
//     Configuration: {
//       WebTest: '<WebTest         Name="${testName}"         Id="00000000-0000-0000-0000-000000000000"         Enabled="True"         CssProjectStructure=""         CssIteration=""         Timeout="120"         WorkItemIds=""         xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010"         Description=""         CredentialUserName=""         CredentialPassword=""         PreAuthenticate="True"         Proxy="default"         StopOnError="False"         RecordedResultFile=""         ResultsLocale="">        <Items>        <Request         Method="GET"         Guid="a86e39d1-b852-55ed-a079-23844e235d01"         Version="1.1"         Url="${testEndpoint}"         ThinkTime="0"         Timeout="120"         ParseDependentRequests="False"         FollowRedirects="True"         RecordResult="True"         Cache="False"         ResponseTimeGoal="0"         Encoding="utf-8"         ExpectedHttpStatusCode="200"         ExpectedResponseUrl=""         ReportingName=""         IgnoreHttpStatusCode="False" />        </Items>        </WebTest>'
//     }
//   }
// }

output appInsightsInstrumentationKey string = AppInsights_webSiteName.properties.InstrumentationKey
output appInsightsConnectionString string = AppInsights_webSiteName.properties.ConnectionString

param logicAppName string
param location string
param defaultTags object

param connections_azuretables_externalid string = '/subscriptions/${subscription().subscriptionId}/resourceGroups/TwitterHOL/providers/Microsoft.Web/connections/azuretables'
param connections_cognitiveservicestextanalytics_externalid string = '/subscriptions/${subscription().subscriptionId}/resourceGroups/TwitterHOL/providers/Microsoft.Web/connections/cognitiveservicestextanalytics'
param connections_office365_2_externalid string = '/subscriptions/${subscription().subscriptionId}/resourceGroups/TwitterHOL/providers/Microsoft.Web/connections/office365-2'
param connections_twitter_1_externalid string = '/subscriptions/${subscription().subscriptionId}/resourceGroups/TwitterHOL/providers/Microsoft.Web/connections/twitter-1'

resource workflows_MercuryHealth_resource 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  tags: defaultTags
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {
          }
          type: 'Object'
        }
      }
      triggers: {
        When_a_new_tweet_is_posted: {
          recurrence: {
            frequency: 'Hour'
            interval: 1
          }
          evaluatedRecurrence: {
            frequency: 'Minute'
            interval: 1
          }
          splitOn: '@triggerBody()?[\'value\']'
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'twitter_1\'][\'connectionId\']'
              }
            }
            method: 'get'
            path: '/onnewtweet'
            queries: {
              searchQuery: '#MercuryHealth #Health'
            }
          }
        }
      }
      actions: {
        Condition: {
          actions: {
            Insert_Entity: {
              runAfter: {
              }
              type: 'ApiConnection'
              inputs: {
                body: {
                  Location: '@triggerBody()?[\'UserDetails\']?[\'Location\']'
                  Name: '@triggerBody()?[\'UserDetails\']?[\'UserName\']'
                  PartitionKey: 'negative'
                  RowKey: '@body(\'Detect_Sentiment\')?[\'id\']'
                  Score: '@body(\'Detect_Sentiment\')?[\'score\']'
                  Tweet: '@triggerBody()?[\'TweetText\']'
                }
                host: {
                  connection: {
                    name: '@parameters(\'$connections\')[\'azuretables\'][\'connectionId\']'
                  }
                }
                method: 'post'
                path: '/Tables/@{encodeURIComponent(\'twitterdata\')}/entities'
              }
            }
          }
          runAfter: {
            Detect_Sentiment: [
              'Succeeded'
            ]
          }
          expression: {
            and: [
              {
                less: [
                  '@body(\'Detect_Sentiment\')?[\'score\']'
                  '0.3'
                ]
              }
              {
                not: {
                  equals: [
                    '@triggerBody()?[\'UserDetails\']?[\'Location\']'
                    ''
                  ]
                }
              }
            ]
          }
          type: 'If'
        }
        Condition_2: {
          actions: {
            Insert_Entity_2: {
              runAfter: {
              }
              type: 'ApiConnection'
              inputs: {
                body: {
                  Location: '@triggerBody()?[\'UserDetails\']?[\'Location\']'
                  Name: '@triggerBody()?[\'UserDetails\']?[\'UserName\']'
                  PartitionKey: 'neutral'
                  RowKey: '@body(\'Detect_Sentiment\')?[\'id\']'
                  Score: '@body(\'Detect_Sentiment\')?[\'score\']'
                  Tweet: '@triggerBody()?[\'TweetText\']'
                }
                host: {
                  connection: {
                    name: '@parameters(\'$connections\')[\'azuretables\'][\'connectionId\']'
                  }
                }
                method: 'post'
                path: '/Tables/@{encodeURIComponent(\'twitterdata\')}/entities'
              }
            }
          }
          runAfter: {
            Detect_Sentiment: [
              'Succeeded'
            ]
          }
          expression: {
            and: [
              {
                greaterOrEquals: [
                  '@body(\'Detect_Sentiment\')?[\'score\']'
                  '0.3'
                ]
              }
              {
                lessOrEquals: [
                  '@body(\'Detect_Sentiment\')?[\'score\']'
                  '0.7'
                ]
              }
              {
                not: {
                  equals: [
                    '@triggerBody()?[\'UserDetails\']?[\'Location\']'
                    ''
                  ]
                }
              }
            ]
          }
          type: 'If'
        }
        Condition_3: {
          actions: {
            Insert_Entity_3: {
              runAfter: {
              }
              type: 'ApiConnection'
              inputs: {
                body: {
                  Location: '@triggerBody()?[\'UserDetails\']?[\'Location\']'
                  Name: '@triggerBody()?[\'UserDetails\']?[\'UserName\']'
                  PartitionKey: 'positive'
                  RowKey: '@body(\'Detect_Sentiment\')?[\'id\']'
                  Score: '@body(\'Detect_Sentiment\')?[\'score\']'
                  Tweet: '@triggerBody()?[\'TweetText\']'
                }
                host: {
                  connection: {
                    name: '@parameters(\'$connections\')[\'azuretables\'][\'connectionId\']'
                  }
                }
                method: 'post'
                path: '/Tables/@{encodeURIComponent(\'twitterdata\')}/entities'
              }
            }
            Send_an_email: {
              runAfter: {
                Insert_Entity_3: [
                  'Succeeded'
                ]
              }
              type: 'ApiConnection'
              inputs: {
                body: {
                  Body: '@triggerBody()?[\'OriginalTweet\']?[\'TweetText\']'
                  Subject: '@triggerBody()?[\'UserDetails\']?[\'Description\']'
                  To: 'rpagels@microsoft.com'
                }
                host: {
                  connection: {
                    name: '@parameters(\'$connections\')[\'office365\'][\'connectionId\']'
                  }
                }
                method: 'post'
                path: '/Mail'
              }
            }
          }
          runAfter: {
            Detect_Sentiment: [
              'Succeeded'
            ]
          }
          expression: {
            and: [
              {
                greater: [
                  '@body(\'Detect_Sentiment\')?[\'score\']'
                  '0.7'
                ]
              }
              {
                not: {
                  equals: [
                    '@triggerBody()?[\'UserDetails\']?[\'Location\']'
                    ''
                  ]
                }
              }
            ]
          }
          type: 'If'
        }
        Detect_Sentiment: {
          runAfter: {
          }
          type: 'ApiConnection'
          inputs: {
            body: {
              text: '@triggerBody()?[\'TweetText\']'
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'cognitiveservicestextanalytics\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/sentiment'
          }
        }
      }
      outputs: {
      }
    }
    parameters: {
      '$connections': {
        value: {
          azuretables: {
            connectionId: connections_azuretables_externalid
            connectionName: 'azuretables'
            id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/eastus2/managedApis/azuretables'
          }
          cognitiveservicestextanalytics: {
            connectionId: connections_cognitiveservicestextanalytics_externalid
            connectionName: 'cognitiveservicestextanalytics'
            id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/eastus2/managedApis/cognitiveservicestextanalytics'
          }
          office365: {
            connectionId: connections_office365_2_externalid
            connectionName: 'office365-2'
            id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/eastus2/managedApis/office365'
          }
          twitter_1: {
            connectionId: connections_twitter_1_externalid
            connectionName: 'twitter-1'
            id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/eastus2/managedApis/twitter'
          }
        }
      }
    }
  }
}

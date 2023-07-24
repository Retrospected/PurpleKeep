@description('The data collection endpoint to be used.')
param dataCollectionEndpointId string

@description('The log analytics workspace to be used.')
param logAnalyticsWorkspaceId string

@description('The name of the data collection rule to be created.')
param dataCollectionRuleName string

@description('Location for all resources.')
param location string

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: dataCollectionRuleName
  location: location
  kind: 'Windows'
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-AtomicLogs_CL': {
        columns: [
          {
            name: 'TimeGenerated'
            type: 'datetime'
          }
          {
            name: 'RawData'
            type: 'string'
          }
        ]
      }
    }
    dataSources: {
      windowsEventLogs: [
        {
          streams: [
            'Microsoft-Event'
          ]
          xPathQueries: [
            'Application!*[System[(Level=1 or Level=2 or Level=3)]]'
            'Security!*[System[(band(Keywords,13510798882111488))]]'
            'System!*[System[(Level=1 or Level=2 or Level=3)]]'
          ]
          name: 'eventLogsDataSource'
        }
      ]
      logFiles: [
        {
          streams: [
            'Custom-AtomicLogs_CL'
          ]
          filePatterns: [
            'C:\\temp\\atomic_results.csv'
          ]
          format: 'text'
          settings: {
            text: {
              recordStartTimestampFormat: 'ISO 8601'
            }
          }
          name: 'AtomicLogs_CL'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: logAnalyticsWorkspaceId
          name: 'la-108104877'
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Event'
        ]
        destinations: [
          'la-108104877'
        ]
        transformKql: 'source'
        outputStream: 'Microsoft-Event'
      }
      {
        streams: [
          'Custom-AtomicLogs_CL'
        ]
        destinations: [
          'la-108104877'
        ]
        transformKql: '''
          source 
          | extend RawData = tostring(RawData) 
          | where not(RawData contains_cs "Execution Time") 
          | project TimeGenerated, ExecutionTime_UTC = todatetime(split(RawData, ",")[0]), ExecutionTime_Local = todatetime(split(RawData, ",")[1]), Technique = trim('"', tostring(split(RawData, ",")[2])), TestName = trim('"', tostring(split(RawData, ",")[4])), Hostname = trim('"', tostring(split(RawData, ",")[5])), Username = trim('"', tostring(split(RawData, ",")[6])), TestGUID = toguid(trim('"', split(RawData, ",")[7]))
        '''
        outputStream: 'Custom-AtomicLogs_CL'
      }
    ]
  }
}

output dataCollectionRuleId string = dataCollectionRule.id

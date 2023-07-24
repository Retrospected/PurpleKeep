@description('Location for all resources.')
param location string

@description('The name of the log analytics workspace to be created.')
param logAnalyticsWorkspaceName string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

resource heartbeatTable 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'Heartbeat'
  properties: {
    retentionInDays: 30
  }
}


resource windowsEventsSystemDataSource 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: logAnalyticsWorkspace
  name: 'WindowsEventsSystem'
  kind: 'WindowsEvent'
  properties: {
    eventLogName: 'System'
    eventTypes: [
      {
        eventType: 'Error'
      }
      {
        eventType: 'Warning'
      }
    ]
  }
}

resource WindowsEventApplicationDataSource 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = {
  parent: logAnalyticsWorkspace
  name: 'WindowsEventsApplication'
  kind: 'WindowsEvent'
  properties: {
    eventLogName: 'Application'
    eventTypes: [
      {
        eventType: 'Error'
      }
      {
        eventType: 'Warning'
      }
      {
        eventType: 'Information'
      }
    ]
  }
}

resource atomicLogsTable 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: logAnalyticsWorkspace
  name: 'AtomicLogs_CL'
  properties: {
    totalRetentionInDays: 30
    plan: 'Analytics'
    schema: {
      name: 'AtomicLogs_CL'
      columns: [
        {
          name: 'TimeGenerated'
          type: 'dateTime'
          description: 'Time Generated'
        }
        {
          name: 'ExecutionTime_Local'
          type: 'dateTime'
          description: 'Time of execution in local time'
        }
        {
          name: 'ExecutionTime_UTC'
          type: 'dateTime'
          description: 'Time of execution in UTC'
        }
        {
          name: 'Technique'
          type: 'string'
          description: 'MITRE Technique ID'
        }
        {
          name: 'TestName'
          type: 'string'
          description: 'Atomic test name'
        }
        {
          name: 'Hostname'
          type: 'string'
          description: 'Hostname'
        }
        {
          name: 'Username'
          type: 'string'
          description: 'Username'
        }
        {
          name: 'TestGUID'
          type: 'guid'
          description: 'Randomly generated GUID'
        }
        {
          name: 'RawData'
          type: 'string'
          description: 'Raw Data'
        }
      ]
    }
    retentionInDays: 30
  }
}

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id

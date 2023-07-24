@description('The name of the data collection endpoint to be created.')
param dataCollectionEndpointName string

@description('Location for all resources.')
param location string

resource dataCollectionEndpoint 'Microsoft.Insights/dataCollectionEndpoints@2022-06-01' = {
  name: dataCollectionEndpointName
  location: location
  properties: {
    configurationAccess: {}
    logsIngestion: {}
    networkAcls: {
      publicNetworkAccess: 'Enabled'
    }
  }
}

output dataCollectionEndpointId string = dataCollectionEndpoint.id

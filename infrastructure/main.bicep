@description('The name that will be used as prefix of your resources')
param name string

@description('Location for all resources.')
param location string

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Size of the virtual machine.')
param vmSize string

@description('Username for the Virtual Machine.')
param adminUsername string = toLower('${name}')

@description('Name of the virtual machine.')
param vmName string = toLower('${name}-vm')

@description('The name of the key vault to be created.')
param keyVaultName string = toLower('${name}-kv')

@description('The data collection endpoint to be used.')
param dataCollectionEndpointName string = toLower('${name}-dce')

@description('The log analytics workspace to be used.')
param logAnalyticsWorkspaceName string = toLower('${name}-la')

@description('The name of the key vault to be created.')
param dataCollectionRuleName string = toLower('${name}-dcr')

module keyVault 'resources/kv.bicep' = {
  name: keyVaultName
  params: {
    keyVaultName: keyVaultName
    location: location
  }
}

module dataCollectionEndpoint 'resources/dce.bicep' = {
  name: dataCollectionEndpointName
  params: {
    dataCollectionEndpointName: dataCollectionEndpointName
    location: location
  }
}

module logAnalyticsWorkspace 'resources/la.bicep' = {
  name: logAnalyticsWorkspaceName
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    location: location
  }
}

module dataCollectionRule 'resources/dcr.bicep' = {
  dependsOn: [
    dataCollectionEndpoint
    logAnalyticsWorkspace
  ]
  name: dataCollectionRuleName
  params: {
    dataCollectionRuleName: dataCollectionRuleName
    location: location
    dataCollectionEndpointId: dataCollectionEndpoint.outputs.dataCollectionEndpointId
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.logAnalyticsWorkspaceId
  }
}

module virtualMachine 'resources/vm.bicep' = {
  dependsOn: [
    dataCollectionRule
    keyVault
  ]
  name: vmName
  params: {
    vmName: vmName
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: location
    vmSize: vmSize
    dataCollectionEndpointId: dataCollectionEndpoint.outputs.dataCollectionEndpointId
    dataCollectionRuleId: dataCollectionRule.outputs.dataCollectionRuleId
  }
}

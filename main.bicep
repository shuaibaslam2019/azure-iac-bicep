@allowed([
  'dev'
  'prod'
  'test'
])
@description('The environment type for the deployment. Allowed values are dev, prod, and test.')
param environmentType string = 'dev'

@description('The name of the solution. This is used to insure that the resources created have unique names. By default, it is set to shuaib followed by a unique string based on the resource group ID.')
@minLength(5)
@maxLength(30)
param solutionName string = 'shuaib${uniqueString(resourceGroup().id)}'

@description('The number of instances for the App Service Plan.')
@minValue(1)
@maxValue(10)
param appservicePlanInstanceCount int = 1

@description('The name and the tier of the App Service Plan SKU. By default, it is set to F1 (Free tier).')
param appServicePlanSku object = {
  name: 'F1'
  tier: 'Free'
}

@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

param storageAccountName string = 'shuaib${uniqueString(resourceGroup().id)}'

var storageAccountSKUName = environmentType == 'prod' ? 'Standard_GRS' : 'Standard_LRS'

resource StorageAccount 'Microsoft.Storage/storageAccounts@2023-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSKUName

  }
  kind: 'StorageV2'
}

module appService 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    location: location
    environmentType: environmentType
    solutionName: solutionName
    appServicePlanSku: appServicePlanSku
    appservicePlanInstanceCount: appservicePlanInstanceCount

  }
}

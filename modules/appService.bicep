@allowed([
  'dev'
  'test'
  'prod'
])
@description('The environment type for the deployment. Allowed values are dev, prod, and test.')
param environmentType string

@description('The name of the solution. This is used to insure that the resources created have unique names. By default, it is set to shuaib followed by a unique string based on the resource group ID.')
@minLength(5)
@maxLength(30)
param solutionName string

@description('The number of instances for the App Service Plan.')
@minValue(1)
@maxValue(10)
param appservicePlanInstanceCount int

@description('The name and the tier of the App Service Plan SKU. By default, it is set to F1 (Free tier).')
param appServicePlanSku object

@description('The Azure region into which the resources should be deployed.')
param location string

var appServicePlanName = '${environmentType}-${solutionName}-plan'
var appServiceAppName  = '${environmentType}-${solutionName}-app'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSku.name
    tier: appServicePlanSku.tier
    capacity: appservicePlanInstanceCount
  }
  properties: {
    reserved: false
  }
}

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

output webAppNameHostName string = webApp.properties.defaultHostName

param fleetResourceGroup string = 'flt'

@description('Specify a globally unique name for your Azure Container Registry')
param name string = 'acrfmad${uniqueString(subscription().id, fleetResourceGroup)}'

@description('Enable admin user for ACR')
param adminUserEnabled bool = false

@description('ACR SKU')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Basic'

param tags object
param location string = resourceGroup().location

// Add ACR resource
resource acrResource 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
  }
}

output containerRegistry resource 'Microsoft.ContainerRegistry/registries@2023-07-01' = acrResource

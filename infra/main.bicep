targetScope='subscription'

param fleetName string = 'flt-mgr-${uniqueString(subscription().id, fleetResourceGroup)}'
param fleetLocation string = 'australiaeast'
param tags object = {
  environment: 'test'
  owners: 'fleet'
}
param vmsize string
param fleetResourceGroup string = 'fleet-demo'
param clusterRegistryResourceGroup string = '${fleetResourceGroup}-resources'

@description('Specify a globally unique name for your Azure Container Registry')
param acrName string = 'acrfmad${uniqueString(subscription().id, fleetResourceGroup)}'

@description('Enable admin user for ACR')
param acrAdminUserEnabled bool = false

@description('ACR SKU')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Basic'

// this gets overridden by the values in main.bicepparam
param members array = [
  {
    name: 'member-1-canary-azlinux'
    group: 'canary'
    dnsPrefix: 'member1'
    location: 'eastus2'
    agentCount: 2
    agentVMSize: vmsize
    osType: 'Linux'
    osSku: 'AzureLinux'
    windowsProfile: null
  }
]

resource fltRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: fleetResourceGroup
  location: fleetLocation
}

resource clustersRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: clusterRegistryResourceGroup
  location: fleetLocation
}

module acr './registry.bicep' = {
  scope: resourceGroup(clustersRG.name)
  name: acrName
  params: {
    name: acrName
    location: fleetLocation
    fleetResourceGroup: fleetResourceGroup
    tags: tags
    sku: acrSku
    adminUserEnabled: acrAdminUserEnabled
  }
}

module fleet './fleet.bicep' = {
  scope: resourceGroup(fltRG.name)
  name: fleetName
  params: {
    name: fleetName
    location: fleetLocation
    hubVmSize: vmsize
    tags: tags
  }
}

module member_clusters './member.bicep' =[for member in members: {
  scope: resourceGroup(fltRG.name)
  name: '${member.name}-module'
  params: {
    tags: tags
    clustersResourceGroup: clusterRegistryResourceGroup
    parentFleet: fleet.outputs.fleet
    member: member
    containerRegistry: acr.outputs.containerRegistry
  }
}]

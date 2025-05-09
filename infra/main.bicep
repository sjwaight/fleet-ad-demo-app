targetScope='subscription'

param fleetName string = 'fleet-mgr'
param fleetLocation string = 'australiaeast'
param tags object = {
  environment: 'test'
  owners: 'fleet'
}
param vmsize string = 'Standard_D2ahs_v4'
param fleetResourceGroup string = 'fleet-demo'
param clustersResourceGroup string = '${fleetResourceGroup}-clusters'

// this gets overriden by the values in main.bicepparam
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
  name: clustersResourceGroup
  location: fleetLocation
}

module fleet './fleet.bicep' = {
  scope: resourceGroup(fltRG.name)
  name: fleetName
  params: {
    name: fleetName
    location: fleetLocation
    tags: tags
  }
}

module member_clusters './member.bicep' =[for member in members: {
  scope: resourceGroup(fltRG.name)
  name: '${member.name}-module'
  params: {
    tags: tags
    clustersResourceGroup: clustersResourceGroup
    parentFleet: fleet.outputs.fleet
    member: member
  }
}]

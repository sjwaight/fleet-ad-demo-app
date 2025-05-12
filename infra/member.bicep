param clustersResourceGroup string
param parentFleet resource 'Microsoft.ContainerService/fleets@2025-03-01'
param containerRegistry resource 'Microsoft.ContainerRegistry/registries@2023-07-01'
param tags object
param member object = {
  name: 'member-1-euap-azlinux'
  group: 'canary'
  dnsPrefix: 'member1'
  location: 'eastus2'
  agentCount: 2
  agentVMSize: 'Standard_D2s_v3'
  osType: 'Linux'
  osSku: 'AzureLinux'
}

module clusterResource './cluster.bicep' = {
  scope: resourceGroup(clustersResourceGroup)
  name: member.name
  params: {
    tags: tags
    member: member
    containerRegistry: containerRegistry
  }
}

resource fleet 'Microsoft.ContainerService/fleets@2025-03-01' existing = {
  name: parentFleet.name
  scope: resourceGroup()
}

resource members_resource 'Microsoft.ContainerService/fleets/members@2025-03-01' = {
  parent: fleet
  name: member.name

  properties: {
    clusterResourceId: clusterResource.outputs.cluster.clusterId
    group: member.group
  }
}

output cluster object = clusterResource.outputs.cluster

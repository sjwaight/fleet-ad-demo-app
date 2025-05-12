
param tags object
param containerRegistry resource 'Microsoft.ContainerRegistry/registries@2023-07-01'
// this member object is overridden by the value in main.bicepparam, because it is passed as a parameter to the module.
param member object = {
  name: 'member-1-canary-azlinux'
  group: 'canary'
  dnsPrefix: 'member1'
  location: 'eastus2'
  agentCount: 2
  agentVMSize: 'Standard_D2ahs_v4'
  osType: 'Linux'
  osSku: 'AzureLinux'
  windowsProfile: null
}

var windowsProfile = member.osType == 'Windows' ? member.windowsProfile : null
var defaultAP = [
  {
    name: 'pool'
    count: member.agentCount
    vmSize: member.agentVMSize
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'System'
  }
]

var agentPools = concat(defaultAP, member.osType == 'Windows' ? [
  {
    name: 'win'
    count: 1
    vmSize: member.agentVMSize
    osType: member.osType
    osSKU: member.osSKU
    mode: 'User'
  }
] : [])


resource clusterResource 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: member.name
  location: member.location
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
  properties: {
    dnsPrefix: member.dnsPrefix
    agentPoolProfiles: agentPools
    autoUpgradeProfile: {
      upgradeChannel:'none'
      nodeOSUpgradeChannel: 'Unmanaged'
    }
    windowsProfile: windowsProfile
    networkProfile: {
      networkPlugin: member.osType == 'Windows' ? 'azure' : 'kubenet'
    }
  }
}

// Assign the AcrPull role to the managed identity of each member cluster
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('${member.name}-acrpull-${containerRegistry.name}') 
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull role ID
    principalId: clusterResource.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
}

output cluster object = {
   clusterId: clusterResource.id
   clusterName: clusterResource.name
}

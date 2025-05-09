
param tags object
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

output cluster object = {
   clusterId: clusterResource.id
   clusterName: clusterResource.name
}

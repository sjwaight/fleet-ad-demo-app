param name string
param tags object
param hubVmSize string
param location string = resourceGroup().location

resource fleetResource 'Microsoft.ContainerService/fleets@2025-03-01' = {
  name: name
  tags: tags
  location: location
  properties: {
    hubProfile: {
      agentProfile: {
        vmSize: hubVmSize
      }
      apiServerAccessProfile: {
        enablePrivateCluster: false
      }
      dnsPrefix: name
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource updateStrategy_fast 'Microsoft.ContainerService/fleets/updateStrategies@2025-03-01' = {
  parent: fleetResource
  name: 'fast'
  properties: {
    strategy: {
      stages:[
        {name: 'prod', groups: [ {name: 'group1'}, {name: 'group2'}]}
      ]
    }
  }
}

resource autoupgradeProfile_k8s_rapid 'Microsoft.ContainerService/fleets/autoUpgradeProfiles@2025-03-01' = {
  parent: fleetResource
  name: 'k8slatest-staged'
  properties: {
    channel: 'Rapid'
    nodeImageSelection: {
        type: 'Consistent'
    }
    updateStrategyId: updateStrategy_fast.id
  }
}

output fleet resource 'Microsoft.ContainerService/fleets@2025-03-01' = fleetResource

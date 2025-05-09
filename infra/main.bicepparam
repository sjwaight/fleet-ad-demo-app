using 'main.bicep'

param fleetResourceGroup = 'fleet-demo-kcd'
var vmsize = 'Standard_D2ahs_v4'

param members = [
  {
    name: 'member-1-ad-demo'
    group: 'group1'
    dnsPrefix: 'member1'
    location: 'southafricawest'
    agentCount: 1
    agentVMSize: vmsize
    osType: 'Linux'
    osSku: 'AzureLinux'
  }
  {
    name: 'member-2-ad-demo'
    group: 'group2'
    dnsPrefix: 'member3'
    location: 'koreacentral'
    agentCount: 1
    agentVMSize: vmsize
    osType: 'Linux'
    osSku: 'AzureLinux'
  }
  {
    name: 'member-2-ad-demo'
    group: 'group2'
    dnsPrefix: 'member4'
    location: 'francesouth'
    agentCount: 21
    agentVMSize: vmsize
    osType: 'Linux'
    osSKU: 'AzureLinux'
  }
]

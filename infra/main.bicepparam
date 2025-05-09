using 'main.bicep'

param fleetResourceGroup = 'fleet-ad-demo-rg'
param vmsize = 'standard_a2_v2'

param members = [
  {
    name: 'member-1-ad-demo'
    group: 'group1'
    dnsPrefix: 'member1'
    location: 'japanwest'
    agentCount: 1
    agentVMSize: vmsize
    osType: 'Linux'
    osSku: 'AzureLinux'
  }
  {
    name: 'member-2-ad-demo'
    group: 'group2'
    dnsPrefix: 'member2'
    location: 'koreacentral'
    agentCount: 1
    agentVMSize: vmsize
    osType: 'Linux'
    osSku: 'AzureLinux'
  }
  {
    name: 'member-3-ad-demo'
    group: 'group2'
    dnsPrefix: 'member3'
    location: 'polandcentral'
    agentCount: 1
    agentVMSize: vmsize
    osType: 'Linux'
    osSKU: 'AzureLinux'
  }
]

param location string
param coreServicesTag object
param RandString string

var logAnalyticsWorkspaceName = 'log-core-${location}-001-${RandString}'
var recoveryServiceVaultName = 'rsv-core-${location}-001'

//RSV
resource recoveryServiceVaults 'Microsoft.RecoveryServices/vaults@2023-06-01'={
  name:recoveryServiceVaultName
  location:location
  tags:coreServicesTag
  properties:{
    publicNetworkAccess:'Disabled'
  }
  sku:{
    tier:'Standard'
    name:'Standard'
  }
}
//LAW
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name:logAnalyticsWorkspaceName
  location:location
  tags:coreServicesTag
  properties:{
    features:{
      enableLogAccessUsingOnlyResourcePermissions:true
    }
  }
}

//DNS Zones
resource appServicePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azurewebsites.net'
  location: 'global'
  tags:coreServicesTag
}
resource sqlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink${environment().suffixes.sqlServerHostname}'
  location: 'global'
  tags:coreServicesTag
}
resource storageAccountPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.${environment().suffixes.storage}'
  location: 'global'
  tags:coreServicesTag
}
resource encryptKVPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink${environment().suffixes.keyvaultDns}'
  location: 'global'
  tags:coreServicesTag
}
//
//output DNS Zone names
output appServicePrivateDnsZoneName string = appServicePrivateDnsZone.name
output sqlPrivateDnsZoneName string = sqlPrivateDnsZone.name
output storageAccountPrivateDnsZoneName string = storageAccountPrivateDnsZone.name
output encryptKVPrivateDnsZoneName string = encryptKVPrivateDnsZone.name
//output DNS Zone ids
output appServicePrivateDnsZoneId string = appServicePrivateDnsZone.id
output sqlPrivateDnsZoneId string = sqlPrivateDnsZone.id
output storageAccountPrivateDnsZoneId string = storageAccountPrivateDnsZone.id
output encryptKVPrivateDnsZoneId string = encryptKVPrivateDnsZone.id
//names
output loganalyticsWorkspaceName string = logAnalyticsWorkspace.name
output recoveryServiceVaultName string = recoveryServiceVaults.name
//Zone Groups created in Spoke.bicep

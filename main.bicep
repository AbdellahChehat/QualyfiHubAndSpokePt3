param RandString string

//All parameters defined in PARAMETERS file.
param location string

param coreVnetName string
param hubVnetName string

param prodVnetAddressPrefix string
param devVnetAddressPrefix string
param coreVnetAddressPrefix string
param hubVnetAddressPrefix string

//tags
param hubTag object
param coreTag object
param prodTag object
param devTag object
param coreServicesTag object

param CoreSecVaultName string
param CoreSecVaultSubID string
param CoreSecVaultRGName string
var CoreEncryptKeyVaultName = 'kv-encrypt-core-${RandString}'
var DefaultNSGName ='defaultNSG'

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: CoreSecVaultName
  scope: resourceGroup(CoreSecVaultSubID, CoreSecVaultRGName)
}
resource defaultNSG 'Microsoft.Network/networkSecurityGroups@2023-05-01' ={
  name: DefaultNSGName
  location:location
  tags:coreServicesTag
}
resource routeTable 'Microsoft.Network/routeTables@2019-11-01' = {
  name: 'routetable-${location}-001'
  location: location
  tags:hubTag
}
module coreServices 'modules/coreServices.bicep'={
  name:'coreServicesDeployment'
  params:{
    location:location
    RandString:RandString
    coreServicesTag:coreServicesTag
  }
}

module hub 'modules/hub.bicep'={
  name:'hubDeployment'
  params:{
    location:location
    vnetAddressPrefix:hubVnetAddressPrefix
    virtualNetworkPrefix:hubVnetName
    //prodAppServiceName:prodAppServiceName
    logAnalyticsWorkspaceName:coreServices.outputs.loganalyticsWorkspaceName
    hubTag:hubTag
    coreServicesTag:coreServicesTag
    appServicePrivateDnsZoneName :coreServices.outputs.appServicePrivateDnsZoneName
    sqlPrivateDnsZoneName:coreServices.outputs.sqlPrivateDnsZoneName
    storageAccountPrivateDnsZoneName:coreServices.outputs.storageAccountPrivateDnsZoneName
  }
}
module core 'modules/core.bicep'={
  name:'coreDeployment'
  params:{
    location:location
    vnetAddressPrefix:coreVnetAddressPrefix
    virtualNetworkPrefix:coreVnetName
    adminUsername:keyVault.getSecret('VMAdminUsername')
    adminPassword:keyVault.getSecret('VMAdminPassword')
    defaultNSGName:defaultNSG.name
    routeTableName:routeTable.name
    logAnalyticsWorkspaceName:coreServices.outputs.loganalyticsWorkspaceName
    recoveryServiceVaultName:coreServices.outputs.recoveryServiceVaultName
    CoreEncryptKeyVaultName:CoreEncryptKeyVaultName
    RecoverySAName:'sacore${location}${RandString}'
    coreTag:coreTag
    hubVnetId:hub.outputs.vnetID
    hubVnetName:hub.outputs.vnetName
    coreServicesTag:coreServicesTag
    appServicePrivateDnsZoneName :coreServices.outputs.appServicePrivateDnsZoneName
    sqlPrivateDnsZoneName:coreServices.outputs.sqlPrivateDnsZoneName
    storageAccountPrivateDnsZoneName:coreServices.outputs.storageAccountPrivateDnsZoneName
    keyVaultPrivateDnsZoneId :coreServices.outputs.encryptKVPrivateDnsZoneId
  }
}
module devSpoke 'modules/spoke.bicep'={
   name:'devSpokeDeployment'
   params:{
     location:location
     spokeType:'dev'
     vnetAddressPrefix:devVnetAddressPrefix
     randString: RandString
     adminUsername:keyVault.getSecret('SQLAdminUsername')
     adminPassword:keyVault.getSecret('SQLAdminPassword')
     defaultNSGName:defaultNSG.name
     routeTableName:routeTable.name
     appServicePrivateDnsZoneName:coreServices.outputs.appServicePrivateDnsZoneName
     sqlPrivateDnsZoneName:coreServices.outputs.sqlPrivateDnsZoneName
     storageAccountPrivateDnsZoneName:coreServices.outputs.storageAccountPrivateDnsZoneName
     logAnalyticsWorkspaceName:coreServices.outputs.loganalyticsWorkspaceName
     tagSpoke:devTag
     hubVnetId:hub.outputs.vnetID
     hubVnetName:hub.outputs.vnetName
     coreServicesTag:coreServicesTag
     appServicePrivateDnsZoneId :coreServices.outputs.appServicePrivateDnsZoneId
     sqlPrivateDnsZoneId :coreServices.outputs.sqlPrivateDnsZoneId
     storageAccountPrivateDnsZoneId  :coreServices.outputs.storageAccountPrivateDnsZoneId
   }
   dependsOn:[
     prodSpoke
   ]
} 
module prodSpoke 'modules/spoke.bicep'={
  name:'prodSpokeDeployment'
  params:{
    location:location
    spokeType:'prod'
    vnetAddressPrefix:prodVnetAddressPrefix
    randString: RandString
    adminUsername:keyVault.getSecret('SQLAdminUsername')
    adminPassword:keyVault.getSecret('SQLAdminPassword')
    defaultNSGName:defaultNSG.name
    routeTableName:routeTable.name
    appServicePrivateDnsZoneName:coreServices.outputs.appServicePrivateDnsZoneName
    sqlPrivateDnsZoneName:coreServices.outputs.sqlPrivateDnsZoneName
    storageAccountPrivateDnsZoneName:coreServices.outputs.storageAccountPrivateDnsZoneName
    logAnalyticsWorkspaceName:coreServices.outputs.loganalyticsWorkspaceName
    tagSpoke:prodTag
    hubVnetId:hub.outputs.vnetID
    hubVnetName:hub.outputs.vnetName
    coreServicesTag:coreServicesTag
    appServicePrivateDnsZoneId :coreServices.outputs.appServicePrivateDnsZoneId
    sqlPrivateDnsZoneId :coreServices.outputs.sqlPrivateDnsZoneId
    storageAccountPrivateDnsZoneId  :coreServices.outputs.storageAccountPrivateDnsZoneId
  }
  dependsOn:[core]
}


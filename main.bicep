param RandString string
//All parameters defined in PARAMETERS file.
param location string
param CoreSecVaultName string
param CoreSecVaultSubID string
param CoreSecVaultRGName string

var CoreEncryptKeyVaultName = 'kv-encrypt-core-${RandString}'
var DefaultNSGName ='defaultNSG'
//Loads in the configuration for modules.
var bicepConfigList = loadJsonContent('./bicepConfig.json')
var spokeList = [for item in items(bicepConfigList.spokeList):item.key ] //Checks which spokes need to be deployed via the list

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: CoreSecVaultName
  scope: resourceGroup(CoreSecVaultSubID, CoreSecVaultRGName)
}
resource defaultNSG 'Microsoft.Network/networkSecurityGroups@2023-05-01' ={
  name: DefaultNSGName
  location:location
  tags:bicepConfigList.coreServices.tags
}
resource routeTable 'Microsoft.Network/routeTables@2019-11-01' = {
  name: 'routetable-${location}-001'
  location: location
  tags:bicepConfigList.hub.tags
}
module coreServices 'modules/coreServices.bicep'={
  name:'coreServicesDeployment'
  params:{
    location:location
    RandString:RandString
    coreServicesTag:bicepConfigList.coreServices.tags
  }
}

module hub 'modules/hub.bicep'={
  name:'hubDeployment'
  params:{
    location:location
    vnetAddressPrefix:bicepConfigList.hub.vnetAddressPrefix
    virtualNetworkNamePrefix:bicepConfigList.hub.vnetName
    logAnalyticsWorkspaceId:coreServices.outputs.loganalyticsWorkspaceId
    hubTag:bicepConfigList.hub.tags
    coreServicesTag:bicepConfigList.coreServices.tags
    appServicePrivateDnsZoneName :coreServices.outputs.appServicePrivateDnsZoneName
    sqlPrivateDnsZoneName:coreServices.outputs.sqlPrivateDnsZoneName
    storageAccountPrivateDnsZoneName:coreServices.outputs.storageAccountPrivateDnsZoneName
  }
}
module core 'modules/core.bicep'={
  name:'coreDeployment'
  params:{
    location:location
    vnetAddressPrefix:bicepConfigList.core.vnetAddressPrefix
    virtualNetworkNamePrefix:bicepConfigList.core.vnetName
    //adminUsername:keyVault.getSecret('VMAdminUsername')
    //adminPassword:keyVault.getSecret('VMAdminPassword')
    CoreEncryptKeyVaultName:CoreEncryptKeyVaultName
    coreTag:bicepConfigList.core.tags
    coreServicesTag:bicepConfigList.coreServices.tags
    defaultNSGId:defaultNSG.id
    routeTableId:routeTable.id
    hubVnetId:hub.outputs.vnetID
    hubVnetName:hub.outputs.vnetName
    //logAnalyticsWorkspaceId:coreServices.outputs.loganalyticsWorkspaceId
    //recoveryServiceVaultName:coreServices.outputs.recoveryServiceVaultName
    //recoveryServiceVaultId:coreServices.outputs.recoveryServiceVaultId
    RecoverySAName:'sacore${location}${RandString}'
    appServicePrivateDnsZoneName :coreServices.outputs.appServicePrivateDnsZoneName
    sqlPrivateDnsZoneName:coreServices.outputs.sqlPrivateDnsZoneName
    storageAccountPrivateDnsZoneName:coreServices.outputs.storageAccountPrivateDnsZoneName
    keyVaultPrivateDnsZoneId :coreServices.outputs.encryptKVPrivateDnsZoneId
  }
}
module spokes 'modules/spoke.bicep'= [for spoke in spokeList : {
   name:'${spoke}Deployment'
   params:{
     location:location
     spokeType:bicepConfigList.spokes[spoke].vnetName
     vnetAddressPrefix:bicepConfigList.spokes[spoke].vnetAddressPrefix
     randString: RandString
     adminUsername:keyVault.getSecret('SQLAdminUsername')
     adminPassword:keyVault.getSecret('SQLAdminPassword')
     tagSpoke:bicepConfigList.spokes[spoke].tags

     appServicePlanSkuName:bicepConfigList.spokes[spoke].appServicePlanSkuName
     linuxFxVersion:bicepConfigList.spokes[spoke].linuxFxVersion
     storageAccountSkuName:bicepConfigList.spokes[spoke].storageAccountSkuName
     sqlDatabaseSku:bicepConfigList.spokes[spoke].sqlDatabaseSku
     repoURL:bicepConfigList.spokes[spoke].repoURL
     branch:bicepConfigList.spokes[spoke].branch

     hubVnetId:hub.outputs.vnetID
     hubVnetName:hub.outputs.vnetName
     coreServicesTag:bicepConfigList.coreServices.tags
     defaultNSGId:defaultNSG.id
     routeTableId:routeTable.id
     logAnalyticsWorkspaceId:coreServices.outputs.loganalyticsWorkspaceId
     appServicePrivateDnsZoneId :coreServices.outputs.appServicePrivateDnsZoneId
     sqlPrivateDnsZoneId :coreServices.outputs.sqlPrivateDnsZoneId
     storageAccountPrivateDnsZoneId  :coreServices.outputs.storageAccountPrivateDnsZoneId
     appServicePrivateDnsZoneName:coreServices.outputs.appServicePrivateDnsZoneName
     sqlPrivateDnsZoneName:coreServices.outputs.sqlPrivateDnsZoneName
     storageAccountPrivateDnsZoneName:coreServices.outputs.storageAccountPrivateDnsZoneName
   }
   dependsOn:[core]
}
]


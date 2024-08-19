param RandString string

//All parameters defined in PARAMETERS file.
param location string
param GatewaySubnetName string
param AppgwSubnetName string
param AzureFirewallSubnetName string
param AzureBastionSubnetName string
param DefaultNSGName string
param firewallName string

param coreVnetName string
param devVnetName string
param hubVnetName string
param prodVnetName string

param devAppServicePlanName string
param devAppServiceName string
param prodAppServicePlanName string
param prodAppServiceName string
param logAnalyticsWorkspaceName string
param recoveryServiceVaultName string

param prodVnetAddressPrefix string
param devVnetAddressPrefix string
param coreVnetAddressPrefix string
param hubVnetAddressPrefix string

param prodVnetAddress string
param devVnetAddress string
param coreVnetAddress string
param hubVnetAddress string

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
    coreVnetName :coreVnetName
    devVnetName :devVnetName
    hubVnetName :hubVnetName
    prodVnetName :prodVnetName
    location:location
    logAnalyticsWorkspaceName:logAnalyticsWorkspaceName
    recoveryServiceVaultName:recoveryServiceVaultName
    coreVnetAddress:coreVnetAddress
    devVnetAddress: devVnetAddress
    prodVnetAddress:prodVnetAddress
    hubVnetAddress: hubVnetAddress
    devTag:devTag
    hubTag:hubTag
    coreTag:coreTag
    prodTag:prodTag
    coreServicesTag:coreServicesTag
  }
}
module devSpoke 'modules/spoke.bicep'={
  name:'devSpokeDeployment'
  params:{
    location:location
    devOrProd:'dev'
    vnetAddressPrefix:devVnetAddressPrefix
    randString: RandString
    adminUsername:keyVault.getSecret('SQLAdminUsername')
    adminPassword:keyVault.getSecret('SQLAdminPassword')
    defaultNSGName:defaultNSG.name
    routeTableName:routeTable.name
    appServicePrivateDnsZoneName:coreServices.outputs.appServicePrivateDnsZoneName
    sqlPrivateDnsZoneName:coreServices.outputs.sqlPrivateDnsZoneName
    storageAccountPrivateDnsZoneName:coreServices.outputs.storageAccountPrivateDnsZoneName
    appServiceName:devAppServiceName
    appServicePlanName:devAppServicePlanName
    logAnalyticsWorkspaceName:logAnalyticsWorkspaceName
    tagSpoke:devTag
  }
  dependsOn:[coreServices]
}

module prodSpoke 'modules/spoke.bicep'={
  name:'prodSpokeDeployment'
  params:{
    location:location
    devOrProd:'prod'
    vnetAddressPrefix:prodVnetAddressPrefix
    randString: RandString
    adminUsername:keyVault.getSecret('SQLAdminUsername')
    adminPassword:keyVault.getSecret('SQLAdminPassword')
    defaultNSGName:defaultNSG.name
    routeTableName:routeTable.name
    appServicePrivateDnsZoneName:coreServices.outputs.appServicePrivateDnsZoneName
    sqlPrivateDnsZoneName:coreServices.outputs.sqlPrivateDnsZoneName
    storageAccountPrivateDnsZoneName:coreServices.outputs.storageAccountPrivateDnsZoneName
    appServiceName:prodAppServiceName
    appServicePlanName:prodAppServicePlanName
    logAnalyticsWorkspaceName:logAnalyticsWorkspaceName
    tagSpoke:prodTag
  }
  dependsOn:[coreServices]
}

module hub 'modules/hub.bicep'={
  name:'hubDeployment'
  params:{
    location:location
    vnetAddressPrefix:hubVnetAddressPrefix
    GatewaySubnetName:GatewaySubnetName
    AppgwSubnetName:AppgwSubnetName
    AzureFirewallSubnetName:AzureFirewallSubnetName
    AzureBastionSubnetName:AzureBastionSubnetName
    firewallName:firewallName
    prodAppServiceName:prodAppServiceName
    logAnalyticsWorkspaceName:logAnalyticsWorkspaceName
    hubTag:hubTag
  }
  dependsOn:[coreServices
    //prodSpoke
    ]
}
/*
module hubGateway 'modules/hubGateway.bicep'= {
  name:'hubGatewayDeployment'
  params:{
    GatewaySubnetName: hub.outputs.HubGatewayName
    location: location
    virtualNetworkName: hub.outputs.HubVNName
  }
  dependsOn:[hub
    peerings] // so deploys at end
}
*/
module core 'modules/core.bicep'={
  name:'coreDeployment'
  params:{
    location:location
    vnetAddressPrefix:coreVnetAddressPrefix
    adminUsername:keyVault.getSecret('VMAdminUsername')
    adminPassword:keyVault.getSecret('VMAdminPassword')
    defaultNSGName:defaultNSG.name
    routeTableName:routeTable.name
    logAnalyticsWorkspaceName:logAnalyticsWorkspaceName
    recoveryServiceVaultName:recoveryServiceVaultName
    keyVaultPrivateDnsZoneName:coreServices.outputs.encryptKVPrivateDnsZoneName
    CoreEncryptKeyVaultName:CoreEncryptKeyVaultName
    RecoverySAName:'sacore${location}${RandString}'
    coreTag:coreTag
  }
  dependsOn:[coreServices]
}
module peerings 'modules/peerings.bicep'={
  name:'peeringsDeployment'
  params:{
    location:location
    firewallPrivateIP:hub.outputs.firewallPrivateIP
    hubTag:hubTag
  }
  dependsOn:[
    devSpoke
    //prodSpoke
    hub
    core
  ]
}

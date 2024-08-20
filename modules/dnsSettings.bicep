
param coreServicesTag object
param appServicePrivateDnsZoneName string
param sqlPrivateDnsZoneName string
param storageAccountPrivateDnsZoneName string

param coreVnetId string
param devVnetId string
param prodVnetId string
param hubVnetId string

param prodAppServicePrivateEndpointName string
param prodSqlServerPrivateEndpointName string
param prodStorageAccountPrivateEndpointName string
param devAppServicePrivateEndpointName string
param devSqlServerPrivateEndpointName string
param coreKeyVaultPrivateEndpointName string

param appServicePrivateDnsZoneId string
param sqlPrivateDnsZoneId string
param storageAccountPrivateDnsZoneId  string
param keyVaultPrivateDnsZoneId string

//DNS Links
//core
resource CoreAppServiceLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${appServicePrivateDnsZoneName}/link-core'
  location: 'global'
  tags:coreServicesTag
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: coreVnetId
    }
  }
}
resource CoreSQLLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${sqlPrivateDnsZoneName}/link-core'
  location: 'global'
  tags:coreServicesTag
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: coreVnetId
    }
  }
}
resource CoreStorageAccountLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${storageAccountPrivateDnsZoneName}/link-core'
  location: 'global'
  tags:coreServicesTag
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: coreVnetId
    }
  }
}
//dev
resource DevAppServiceLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${appServicePrivateDnsZoneName}/link-dev'
  location: 'global'
  tags:coreServicesTag
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: devVnetId
    }
  }
}
resource DevSQLLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${sqlPrivateDnsZoneName}/link-dev'
  location: 'global'
  tags:coreServicesTag
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: devVnetId
    }
  }
}
//hub
resource HubAppServiceLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${appServicePrivateDnsZoneName}/link-hub'
  location: 'global'
  tags:coreServicesTag
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: hubVnetId
    }
  }
}
resource HubSQLLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${sqlPrivateDnsZoneName}/link-hub'
  location: 'global'
  tags:coreServicesTag
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: hubVnetId
    }
  }
}
resource HubStorageAccountLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${storageAccountPrivateDnsZoneName}/link-hub'
  location: 'global'
  tags:coreServicesTag
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: hubVnetId
    }
  }
}
//prod
resource ProdAppServiceLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${appServicePrivateDnsZoneName}/link-prod'
  location: 'global'
  tags:coreServicesTag
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: prodVnetId
    }
  }
}
resource ProdSQLLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${sqlPrivateDnsZoneName}/link-prod'
  location: 'global'
  tags:coreServicesTag
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: prodVnetId
    }
  }
}
resource ProdStorageAccountLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${storageAccountPrivateDnsZoneName}/link-prod'
  location: 'global'
  tags:coreServicesTag
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: prodVnetId
    }
  }
}

//Prod DNS Settings
resource prodASPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  name: '${prodAppServicePrivateEndpointName}/dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: appServicePrivateDnsZoneId
        }
      }
    ]
  }
}
resource prodSqlPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  name: '${prodSqlServerPrivateEndpointName}/dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: sqlPrivateDnsZoneId
        }
      }
    ]
  }
}
resource prodStorageAccountPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  name: '${prodStorageAccountPrivateEndpointName}/dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: storageAccountPrivateDnsZoneId
        }
      }
    ]
  }
}

//Dev DNS Settings
resource devASPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  name: '${devAppServicePrivateEndpointName}/dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: appServicePrivateDnsZoneId
        }
      }
    ]
  }
}
resource devSqlPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  name: '${devSqlServerPrivateEndpointName}/dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: sqlPrivateDnsZoneId
        }
      }
    ]
  }
}

//Core DNS Settings
resource corePrivateEndpointDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  name: '${coreKeyVaultPrivateEndpointName}/dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: keyVaultPrivateDnsZoneId
        }
      }
    ]
  }
}


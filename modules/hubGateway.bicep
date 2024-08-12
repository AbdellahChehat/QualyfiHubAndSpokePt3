param location string
param virtualNetworkName string
param GatewaySubnetName string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: virtualNetworkName
}

//HubGateway
resource HubGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {name: GatewaySubnetName,parent: virtualNetwork}
resource hubGatewayPIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'pip-hubGateway-hub-${location}-001'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}
resource hubGateway 'Microsoft.Network/virtualNetworkGateways@2023-05-01' ={
  name:'hubGateway-hub-${location}-001'
  location:location
  properties:{
    ipConfigurations:[{
      name:'ipconfig'
      properties:{
        publicIPAddress:{ id:hubGatewayPIP.id}
        subnet:{id:HubGatewaySubnet.id}
      }
    }]
  }
}

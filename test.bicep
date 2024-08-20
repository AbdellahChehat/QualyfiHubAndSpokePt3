var location ='uksouth'


resource defaultNSG 'Microsoft.Network/networkSecurityGroups@2023-05-01' ={
  name: 'defaultNSG'
  location:location
}

/*
resource virtualNetwork1 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: 'VNet1'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '15.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '15.0.1.0/24'
          networkSecurityGroup:{  id: defaultNSG.id }
        }
      }
    ]
  }
}
*/

resource virtualNetwork2 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: 'VNet2'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '16.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '16.0.1.0/24'
          networkSecurityGroup:{  id: defaultNSG.id }
        }
      }
    ]
  }
}

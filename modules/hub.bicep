

param location string
param vnetAddressPrefix string
//param logAnalyticsWorkspaceId string
param hubTag object
param coreServicesTag object
param appServicePrivateDnsZoneName string
param sqlPrivateDnsZoneName string
param storageAccountPrivateDnsZoneName string
param virtualNetworkNamePrefix string

var GatewaySubnetAddressPrefix ='1'
var AppgwSubnetAddressPrefix ='2'
var AzureFirewallSubnetAddressPrefix ='3'
var AzureBastionSubnetAddressPrefix ='4'

var firewallSubnetName = 'AzureFirewallSubnet'
var gatewaySubnetName ='GatewaySubnet'
var appGWSubnetName ='AppgwSubnet'
var bastionSubnetName ='AzureBastionSubnet'
//var appGatewayPIPName = 'pip-appGateway-hub-${location}-001'
//var appGatewayName = 'appGateway-hub-${location}-001'//var appgw_id = resourceId('Microsoft.Network/applicationGateways','appGateway-hub-${location}-001')
//var bastionPIPName ='pip-bastion-hub-${location}-001'
//var bastionName ='bastion-hub-${location}-001'
//var firewallPIPName = 'pip-firewall-hub-${location}-001'
//var firewallPolicyName ='firewallPolicy-hub-${location}-001' 
//var firewallRulesName ='firewallRules-hub-${location}-001'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'vnet-${virtualNetworkNamePrefix}-${location}-001'
  location: location
  tags:hubTag
  properties: {
    addressSpace: {
      addressPrefixes: [
        '${vnetAddressPrefix}.0.0/16'
      ]
    }
    subnets: [
      {
        name: gatewaySubnetName
        properties: {
          addressPrefix: '${vnetAddressPrefix}.${GatewaySubnetAddressPrefix}.0/24'
        }
      }
      {
        name: appGWSubnetName
        properties: {
          addressPrefix: '${vnetAddressPrefix}.${AppgwSubnetAddressPrefix}.0/24'
        }
      }
      {
        name: firewallSubnetName
        properties: {
          addressPrefix: '${vnetAddressPrefix}.${AzureFirewallSubnetAddressPrefix}.0/24'
        }
      }
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: '${vnetAddressPrefix}.${AzureBastionSubnetAddressPrefix}.0/24'
        }
      }
    ]
  }
}
/*
//Firewall Code
resource FirewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {name: AzureFirewallSubnetName,parent: virtualNetwork}

resource firewallPIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: firewallPIPName
  location: location
  tags:hubTag
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2023-05-01' ={
  name: firewallName
  location:location
  tags:hubTag
  properties:{
    hubIPAddresses:{
      privateIPAddress: '${vnetAddressPrefix}.${AzureFirewallSubnetAddressPrefix}.4'
    }
    ipConfigurations:[{
      name:'ipconfig'
      properties:{
        publicIPAddress:{ id:firewallPIP.id}
        subnet:{id:FirewallSubnet.id}
      }
    }]
    firewallPolicy:{id:firewallPolicy.id}
  }
}

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2021-05-01' = {
  name: firewallPolicyName
  tags:hubTag
  location: location
}
resource firewallRuleCollection 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-05-01' ={
  name: firewallRulesName
  parent: firewallPolicy
  properties:{
    priority: 200
    ruleCollections:[{
      name:'allowAllRule'
      priority: 1100
      ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
      action:{ type:'Allow'}
      rules:[
        {
          name:'Rule1'
          ruleType:'NetworkRule'
          ipProtocols:['Any']
          sourceAddresses:['*']
          destinationAddresses:['*']
          destinationPorts:['*']
        }
      ]
    }]
  }
}
output firewallPrivateIP string = '${vnetAddressPrefix}.${AzureFirewallSubnetAddressPrefix}.4' //firewall.properties.hubIPAddresses.privateIPAddress

resource firewallDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'firewallDiagnosticSettings'
  scope: firewall
  properties: {
    logs: [
      {
        category: ''
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: logAnalyticsWorkspaceId
  }
}
  */

//DNS settings
resource HubAppServiceLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${appServicePrivateDnsZoneName}/link-hub'
  location: 'global'
  tags:coreServicesTag
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
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
      id: virtualNetwork.id
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
      id: virtualNetwork.id
    }
  }
}

output HubGatewayName string = gatewaySubnetName
output HubVNName string = virtualNetwork.name
output vnetID string =virtualNetwork.id
output vnetName string =virtualNetwork.name

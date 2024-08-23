@allowed([
  'dev'
  'prod'
])
param spokeType string = 'dev'
param location string
param vnetAddressPrefix string
param randString string
@secure()
param adminUsername string
@secure()
param adminPassword string
param defaultNSGName string
param routeTableName string
param appServicePrivateDnsZoneName string 
param sqlPrivateDnsZoneName string 
param storageAccountPrivateDnsZoneName string
param logAnalyticsWorkspaceName string
param tagSpoke object
param hubVnetName string
param hubVnetId string
param coreServicesTag object
param appServicePrivateDnsZoneId string
param sqlPrivateDnsZoneId string
param storageAccountPrivateDnsZoneId  string
var appServicePlanSku = 'B1'
var appServiceSubnetName ='AppSubnet'
var SQLServerName = 'sql-${spokeType}-${location}-001-${randString}'
var SQLServerSku = 'Basic'
var SQLDatabaseName = 'sqldb-${spokeType}-${location}-001-${randString}'
var SQLServerSubnetName ='SqlSubnet'
var storageAccountName = 'st${spokeType}001${randString}'
var SASubnetName ='StSubnet'
var appServiceRepoURL = 'https://github.com/Azure-Samples/dotnetcore-docs-hello-world'
var appServicePrivateEndpointName = 'private-endpoint-${appService.name}'
var sqlServerPrivateEndpointName = 'private-endpoint-${sqlServer.name}'
var storageAccountPrivateEndpointName ='private-endpoint-${storageAccount.name}'
var appServicePlanName = 'asp-${spokeType}-${location}-001-${randString}'
var appServiceName = 'as-${spokeType}-${location}-001-${randString}'

var appServiceSubnetObject ={
        name: appServiceSubnetName
        properties: {
          addressPrefix: '${vnetAddressPrefix}.1.0/24'
          networkSecurityGroup:{  id: defaultNSG.id }
          routeTable:{id:routeTable.id}
        }
}
var SQLServerSubnetObject ={
        name: SQLServerSubnetName
        properties: {
          addressPrefix: '${vnetAddressPrefix}.2.0/24'
          networkSecurityGroup:{  id: defaultNSG.id }
          routeTable:{id:routeTable.id}
        }
}
var SASubnetObject ={
        name: SASubnetName
        properties: {
          addressPrefix: '${vnetAddressPrefix}.3.0/24'
          networkSecurityGroup: { id: defaultNSG.id }
          routeTable: { id: routeTable.id }
        }
}
var prodSubnet = [appServiceSubnetObject,SQLServerSubnetObject,SASubnetObject]
var devSubnet = [appServiceSubnetObject,SQLServerSubnetObject]


resource routeTable 'Microsoft.Network/routeTables@2019-11-01' existing = {name: routeTableName}

resource defaultNSG 'Microsoft.Network/networkSecurityGroups@2023-05-01' existing ={
  name: defaultNSGName
}
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'vnet-${spokeType}-${location}-001'
  location: location
  tags:tagSpoke
  properties: {
    addressSpace: {
      addressPrefixes: [
        '${vnetAddressPrefix}.0.0/16'
      ]
    }
    subnets: spokeType == 'prod' ? prodSubnet : devSubnet
  }
}
resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01'={
  name: '${spokeType}-to-hub-peering'
  parent: virtualNetwork
  properties:{
    allowForwardedTraffic:true
    allowGatewayTransit:true
    allowVirtualNetworkAccess:true
    peeringState:'Connected'
    remoteVirtualNetwork:{
      id: hubVnetId
    }
  }
}
resource hubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01'={
  name: '${hubVnetName}/hub-to-${spokeType}-peering'
  properties:{
    allowForwardedTraffic:true
    allowGatewayTransit:true
    allowVirtualNetworkAccess:true
    peeringState:'Connected'
    remoteVirtualNetwork:{
      id: virtualNetwork.id
    }
  }
}
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name:logAnalyticsWorkspaceName
}
resource storageAccountSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-03-01' = if (spokeType == 'prod') {
  parent: virtualNetwork
  name: SASubnetName
  properties: {
    addressPrefix: '${vnetAddressPrefix}.3.0/24'
    networkSecurityGroup:{  id: defaultNSG.id }
    routeTable:{id:routeTable.id}
  }
}
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01'={
  name: appServicePlanName
  location:location
  tags:tagSpoke
  kind: 'linux'
  sku:{
    name: appServicePlanSku
    tier : 'Basic'
   }
  properties:{
    reserved:true
  }
}
resource appService 'Microsoft.Web/sites@2022-09-01' ={
  name:appServiceName
  location:location
  tags:tagSpoke
  properties:{
    serverFarmId:appServicePlan.id
    siteConfig:{
      linuxFxVersion:'DOTNETCORE|7.0'
      appSettings:[
        {
          name:'APPINSIGHTS_INSTRUMENTATIONKEY'
          value:applicationInsights.properties.InstrumentationKey
        }
        {
          name:'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value:applicationInsights.properties.ConnectionString
        }
        {
          name:'ApplicationInsightsAgent_EXTENSION_VERSION'
          value:'~3'
        }
        {
          name:'XDT_MicrosoftApplicationInsights_Mode'
          value:'default'
        }
      ]
      alwaysOn:true
    }
  }
}
resource codeAppService 'Microsoft.Web/sites/sourcecontrols@2022-09-01' ={
  parent: appService
  name:'web'
  properties:{
    repoUrl:appServiceRepoURL
    isManualIntegration:true
    branch:'master'
  }
  dependsOn:[
    appPrivateDnsZoneGroup
  ]
}
resource AppServiceSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {name: appServiceSubnetName,parent: virtualNetwork
}
resource appServicePrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' ={
  name:appServicePrivateEndpointName
  location:location
  tags:tagSpoke
  properties:{
    subnet:{
      id:AppServiceSubnet.id
    }
    privateLinkServiceConnections:[
      {
        name:appServicePrivateEndpointName
        properties:{
          privateLinkServiceId: appService.id
          groupIds:[
            'sites'
          ]
        }
  }]
  }
}
resource appServiceDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (spokeType == 'prod') {
  name: '${spokeType}-${location}-aSDiagnosticSettings'
  scope: appService
  properties: {
    logs: [
      {
        category: null
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
    workspaceId: logAnalyticsWorkspace.id
  }
  dependsOn:[
    applicationInsights
  ]
}
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name:'${spokeType}-${location}-aSInsights'
  location:location
  tags:tagSpoke
  kind:'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}
//SQL
resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name:SQLServerName
  location:location
  tags:tagSpoke
  properties:{
    administratorLogin:adminUsername
    administratorLoginPassword:adminPassword
  }
}
resource sqlDB 'Microsoft.Sql/servers/databases@2021-11-01' = {
  name:SQLDatabaseName
  location:location
  tags:tagSpoke
  parent: sqlServer
  sku:{
    name:SQLServerSku
    tier:SQLServerSku
  }
}
resource SQLSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {name: SQLServerSubnetName,parent: virtualNetwork
}
resource sqlServerPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' ={
  name:sqlServerPrivateEndpointName
  location:location
  tags:tagSpoke
  properties:{
    subnet:{
      id:SQLSubnet.id
    }
    privateLinkServiceConnections:[
      {
        name:sqlServerPrivateEndpointName
        properties:{
          privateLinkServiceId: sqlServer.id
          groupIds:[
            'sqlServer'
          ]
        }
  }]
  }
}
//StorageAccount
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = if (spokeType == 'prod') {
  name: storageAccountName
  kind: 'StorageV2'
  tags:tagSpoke
  location: location
  sku:{
    name:'Standard_LRS'
  }
}
resource storageAccountPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = if (spokeType == 'prod') {
  name:storageAccountPrivateEndpointName
  location:location
  tags:tagSpoke
  properties:{
    subnet:{
      id:storageAccountSubnet.id
    }
    privateLinkServiceConnections:[
      {
        name:storageAccountPrivateEndpointName
        properties:{
          privateLinkServiceId: storageAccount.id
          groupIds:[
            'blob'
          ]
        }
  }]
  }
}
//DNS Settings
resource spokeAppServiceLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${appServicePrivateDnsZoneName}/link-${spokeType}'
  location: 'global'
  tags:coreServicesTag
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}
resource spokeSQLLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${sqlPrivateDnsZoneName}/link-${spokeType}'
  location: 'global'
  tags:coreServicesTag
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}
resource spokeStorageAccountLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (spokeType == 'prod') {
  name: '${storageAccountPrivateDnsZoneName}/link-${spokeType}'
  location: 'global'
  tags:coreServicesTag
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource appPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: appServicePrivateEndpoint
  name: 'dnsgroupname'
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
resource sqlPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: sqlServerPrivateEndpoint
  name: 'dnsgroupname'
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
resource storageAccountPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01'= if (spokeType == 'prod') {
  parent: storageAccountPrivateEndpoint
  name: 'dnsgroupname'
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


//output Endpoint names
output appServicePrivateEndpointName string = appServicePrivateEndpoint.name
output sqlServerPrivateEndpointName string = sqlServerPrivateEndpoint.name
output storageAccountPrivateEndpointName string = storageAccountPrivateEndpoint.name
output vnetID string =virtualNetwork.id

//SQLAudit https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/auditingsettings?pivots=deployment-language-bicep
//https://learn.microsoft.com/en-us/sql/relational-databases/security/auditing/sql-server-audit-database-engine?view=sql-server-ver16
//https://learn.microsoft.com/en-us/azure/azure-sql/database/auditing-overview?view=azuresql







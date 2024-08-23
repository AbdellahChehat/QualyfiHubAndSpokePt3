using 'main.bicep'

param location = 'uksouth' // This value must be provided.
param RandString = 'q4huo7'

//Vnet names
param hubVnetName = 'hub'
param coreVnetName = 'core'

param CoreSecVaultName = 'kv-master-dev-uks-01'
param CoreSecVaultSubID = 'e5cfa658-369f-4218-b58e-cece3814d3f1'
param CoreSecVaultRGName = 'rg-kv-master-dev-uks-02'

//Prefixes
param prodVnetAddressPrefix = '10.31'
param devVnetAddressPrefix = '10.30'
param coreVnetAddressPrefix = '10.20'
param hubVnetAddressPrefix = '10.10'

//tags
param hubTag ={ Dept:'Hub', Owner:'HubOwner'}
param coreTag ={ Dept:'Core', Owner:'CoreOwner'}
param prodTag ={ Dept:'Prod', Owner:'ProdOwner'}
param devTag ={ Dept:'Dev', Owner:'DevOwner'}
param coreServicesTag ={ Dept:'CoreServices', Owner:'CoreServicesOwner'}


























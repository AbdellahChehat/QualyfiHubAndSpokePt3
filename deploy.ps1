#Functions for easy repeat
function RandomiseString{
    param (
        [int]$allowedLength = 10,
        [string]$allowedText ="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
    )
    $returnText = -Join($allowedText.tochararray() | Get-Random -Count $allowedLength | ForEach-Object {[char]$_})
    return $returnText
}

#Parameters Decleration
$RGName = "rg-hubandspoke-prod-01" 
$RGLocation = "uksouth" 
$RandomString = (RandomiseString 6 "abcdefghijklmnopqrstuvwxyz1234567890") 
$CoreTags = @{"Area"="CoreServices"}
$KeyVaultRGName = "rg-kv-master-dev-uks-02"
$CoreSecretsKeyVaultName = "kv-master-dev-uks-01"
$CoreEncryptKeyVaultName = "kv-encrypt-core-" + $RandomString
$RecoveryServiceVaultName = 'rsv-core-'+$RGLocation+'-001'
$vmName = 'vm-core-'+$RGLocation+'-001'

# Adds the new random generated value to the biceparam
$bicepParamFilePath = 'parameters.bicepparam'
$bicepParamContent = Get-Content -Raw -Path $bicepParamFilePath
$bicepParamContent = $bicepParamContent -replace "(param RandString\s*=\s*)'.*?'", "`$1'$RandomString'"
Set-Content -Path $bicepParamFilePath -Value $bicepParamContent

# Attempt to get the currently logged in Azure account
$account = Get-AzContext -ErrorAction SilentlyContinue
if ($null -eq $account) { # No Azure account is logged in
    Write-Output "No Azure account is currently logged in. Logging in now..."
    Connect-AzAccount -TenantId d4003661-f87e-4237-9a9b-8b9c31ba2467
} else { Write-Output "You are already logged in."} # An Azure account is already logged in

New-AzResourceGroup -Name $RGName -Location $RGLocation

#Key Vault Properties|	
$VMAdminUsernameP = RandomiseString 
$VMAdminPasswordP = RandomiseString 16 "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz&#$%?!1234567890"
$SQLAdminUsernameP = RandomiseString 
$SQLAdminPasswordP = RandomiseString 16 "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz&#$%?!1234567890"

#Deploy Keyvault and Set Secrets
Set-AzKeyVaultSecret -VaultName $CoreSecretsKeyVaultName -Name "VMAdminUsername" -SecretValue (SecureString $VMAdminUsernameP)
Set-AzKeyVaultSecret -VaultName $CoreSecretsKeyVaultName -Name "VMAdminPassword" -SecretValue (SecureString $VMAdminPasswordP)
Set-AzKeyVaultSecret -VaultName $CoreSecretsKeyVaultName -Name "SQLAdminUsername" -SecretValue (SecureString $SQLAdminUsernameP)
Set-AzKeyVaultSecret -VaultName $CoreSecretsKeyVaultName -Name "SQLAdminPassword" -SecretValue (SecureString $SQLAdminPasswordP)

#Deploy file
# New-AzResourceGroupDeployment -ResourceGroupName $RGName -TemplateFile main.bicep -TemplateParameterFile parameters.bicepparam -RandString $RandomString
New-AzResourceGroupDeploymentStack `
  -Name "deploymentStack" `
  -ResourceGroupName $RGName `
  -TemplateFile "./main.bicep" `
  -TemplateParameterFile "./parameters.bicepparam"  `
  -ActionOnUnmanage "detachAll" `
  -DenySettingsMode "none"

Write-Output "Virtual Machine Admin Username : $VMAdminUsernameP"
Write-Output "Virtual Machine Admin Password : $VMAdminPasswordP"
Write-Output "SQL Admin Password : $SQLAdminUsernameP"
Write-Output "SQL Admin Password : $SQLAdminPasswordP"
Write-Output "CoreSecretsKeyVaultName : $CoreSecretsKeyVaultName"

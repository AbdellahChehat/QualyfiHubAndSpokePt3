#Parameters Decleration
$RGName = "rg-hubandspoke-prod-01" 
$RGLocation = "uksouth"

Set-AzResourceGroupDeploymentStack `
  -Name "deploymentStack" `
  -ResourceGroupName $RGName `
  -TemplateFile "./main.bicep" `
  -TemplateParameterFile "./parameters.bicepparam"  `
  -ActionOnUnmanage "deleteResources" `
  -DenySettingsMode "none"
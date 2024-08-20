$githubOrganizationName = 'js-magar'
$githubRepositoryName = 'QualyfiHubAndSpokePt3'
$nameFC='sp-github-actions-landing-zone-deployment-stack-jash'
$RGName = "rg-hubandspoke-prod-01" 
$applicationRegistration = Get-AzADApplication -DisplayName $namefc
$resourceGroup = Get-AzResourceGroup -Name $RGName
$azureContext = Get-AzContext
Write-Host "AZURE_CLIENT_ID: $($applicationRegistration.AppId)"
Write-Host "AZURE_TENANT_ID: $($azureContext.Tenant.Id)"
Write-Host "AZURE_SUBSCRIPTION_ID: $($azureContext.Subscription.Id)"
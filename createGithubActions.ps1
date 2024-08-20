$githubOrganizationName = 'js-magar'
$githubRepositoryName = 'QualyfiHubAndSpokePt3'
$nameSP='sp-github-actions-landing-zone-deployment-stack-jash'
$nameFC='fc-github-actions-landing-zone-deployment-stack-jash'
$RGName = "rg-jm-hubandspoke-dev-uks-01" 
$applicationRegistration = Get-AzADApplication -DisplayName $namefc
$resourceGroup = Get-AzResourceGroup -Name $RGName
$azureContext = Get-AzContext
Write-Host "AZURE_CLIENT_ID: $($applicationRegistration.AppId)"
Write-Host "AZURE_TENANT_ID: $($azureContext.Tenant.Id)"
Write-Host "AZURE_SUBSCRIPTION_ID: $($azureContext.Subscription.Id)"

$applicationRegistration = New-AzADApplication -DisplayName 'sp-github-actions-landing-zone-deployment-stack-jash'
#$applicationRegistration = New-AzADApplication -DisplayName $nameSP
New-AzADAppFederatedCredential `
   -Name $nameFC `
   -ApplicationObjectId $applicationRegistration.Id `
   -Issuer 'https://token.actions.githubusercontent.com' `
   -Audience 'api://AzureADTokenExchange' `
   -Subject "repo:$($githubOrganizationName)/$($githubRepositoryName):ref:refs/heads/main"
$resourceGroup = Get-AzResourceGroup -Name $RGName
New-AzADServicePrincipal -AppId $($applicationRegistration.AppId)
New-AzRoleAssignment `
  -ApplicationId $($applicationRegistration.AppId) `
  -RoleDefinitionName Contributor `
  -Scope $($resourceGroup.ResourceId)
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
$RandomString = (RandomiseString 6 "abcdefghijklmnopqrstuvwxyz1234567890") 
# Adds the new random generated value to the biceparam
$bicepParamFilePath = 'parameters.bicepparam'
$bicepParamContent = Get-Content -Raw -Path $bicepParamFilePath
$bicepParamContent = $bicepParamContent -replace "(param RandString\s*=\s*)'.*?'", "`$1'$RandomString'"
Set-Content -Path $bicepParamFilePath -Value $bicepParamContent
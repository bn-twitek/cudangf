<#
.SYNOPSIS
This script will configure a management certificate for use with ARM to make API calls
.DESCRIPTION
This is the powershell used in Step 2 of the techlib article https://techlib.barracuda.com/NGF62/AzureAMRUDR it expects you to have already generated the certificates
per step 1 on the NG and have downloaded them to your machine.
.SAMPLE
Upload-Mgmt-Cert.ps1 -ng_external_url "http://ngurl.azure.com" -arm_certificate_path "C:\Temp\arm.cer" -resource_group_path "/subscription/111111111-1111-1111-1111-111111111/resourceGroups/ResourceGroupName"
#> 

param(
[string]$ng_external_url = "http://ngurl.azure.com",
#You need to generate the certificate and download it from the NG first 
[string]$arm_certificate_path = "",
#Path to the resource group containing the vnet
[string]$resource_group_path = "/subscription/111111111-1111-1111-1111-111111111/resourceGroups/ResourceGroupName"
)


#Authenticates against the Azure subscription
try {
    $AzureToolsUserAgentString = New-Object -TypeName System.Net.Http.Headers.ProductInfoHeaderValue -ArgumentList 'VSAzureTools', '1.4'
    [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.UserAgents.Add($AzureToolsUserAgentString)
} catch { }

$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate("$($arm_certificate_path)")
$key = [System.Convert]::ToBase64String($cert.GetRawCertData())
$app = New-AzureRMADApplication -DisplayName "NG" -HomePage "$($ng_external_url )" -IdentifierUris "$($ng_external_url )" -KeyValue $key -KeyType AsymmetricX509Cert

Write-Host $app.ApplicationId

New-AzureRmADServicePrincipal -ApplicationId $app.ApplicationId

New-AzureRmRoleAssignment -RoleDefinitionName "Owner" -ServicePrincipalName $app.ApplicationId -Scope "$($resource_group_path)"

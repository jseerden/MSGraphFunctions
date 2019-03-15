function Connect-GraphApplication() {
    <#
        .SYNOPSIS
            Retrieve an Auth Token for the Application
        .DESCRIPTION
            Retrieve an Auth Token for the AzureAD endpoint, using the Active Directory Authentication Library (ADAL) client library,
            which is included in the AzureAD PowerShell Module.

            https://developer.microsoft.com/en-us/graph/docs/concepts/auth_overview
        .PARAMETER TenantId
            Id of the Tenant for which an Auth Token is requested.
        .PARAMETER ClientId
            Application Id of an Azure AD App registration
        .PARAMETER ClientSecret
            Authentication key of the Azure AD App registration
        .PARAMETER ResourceUri
            REST API endpoint Uri
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TenantId,

        [Parameter(Mandatory = $true)]
        [string]$ClientId,

        [Parameter(Mandatory = $true)]
        [string]$ClientSecret,

        [Parameter(Mandatory = $false)]
        [string]$ResourceUri = "https://graph.microsoft.com"
    )

    process {
        try {
            # Load DLLs
            $azureADModule = Get-Module -Name "AzureAD" -ListAvailable
            if ($null -eq $azureADModule) {
                $azureADModule = Get-Module -Name "AzureADPreview" -ListAvailable
            }
            if ($null -eq $azureADModule) {
                Write-Output "AzureAD Powershell module is not installed. The module can be installed by running 'Install-Module AzureAD' or 'Install-Module AzureADPreview' from an elevated PowerShell prompt. Stopping."
                exit
            }
            if ($azureADModule.count -gt 1) {
                $latestVersion = ($azureADModule | Select-Object version | Sort-Object)[-1]
                $azureADModule  = $azureADModule | Where-Object { $_.version -eq $latestVersion.version }
                $adal           = Join-Path $azureADModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
                $adalForms      = Join-Path $azureADModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
            }
            else {
                $adal           = Join-Path $azureADModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
                $adalForms      = Join-Path $azureADModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
            }
            $null = [System.Reflection.Assembly]::LoadFrom($adal)
            $null = [System.Reflection.Assembly]::LoadFrom($adalForms)

            $credentials = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential" -ArgumentList $clientId, $clientSecret
            $authority = "https://login.microsoftonline.com/$tenantId"
            $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority

            $authResult = $authContext.AcquireTokenAsync($resourceUri, $credentials).Result

            # If the accesstoken is valid then create the authentication header
            if($authResult.AccessToken) {
                # Creating header for Authorization token
                $authHeader = @{
                    'Content-Type' = 'application/json'
                    'Authorization'= "Bearer $($authResult.AccessToken)"
                    'ExpiresOn'    = $authResult.ExpiresOn
                }
        
                $Script:moduleScopeGraphAuthHeader = $authHeader       
                return $moduleScopeGraphAuthHeader
        
            }
            else {
                Write-Error "Authorization Access Token is null, please re-run authentication..." -ErrorAction Stop
            }
        }
        catch {
            $Script:moduleScopeGraphAuthHeader = $null
            $streamReader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $streamReader.BaseStream.Position = 0
            $streamReader.DiscardBufferedData()
            $responseBody = $streamReader.ReadToEnd()

            Write-Error "Request to $($_.Exception.Response.ResponseUri) failed with HTTP Status $($_.Exception.Response.StatusCode) $($_.Exception.Response.StatusDescription). `nResponse content: `n$responseBody"
        }
    }
}
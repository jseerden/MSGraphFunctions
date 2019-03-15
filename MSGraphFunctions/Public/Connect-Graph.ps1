function Connect-Graph() {
    <#
        .SYNOPSIS
            Retrieve an Auth Token with Delegated User Permissions
        .DESCRIPTION
            Retrieve an Auth Token for the AzureAD endpoint, using the Active Directory Authentication Library (ADAL) client library,
            which is included in the AzureAD PowerShell Module.

            https://developer.microsoft.com/en-us/graph/docs/concepts/auth_overview
        .PARAMETER Username
            User authenticating to Microsoft Graph
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Username
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

            $tenant = (New-Object "System.Net.Mail.MailAddress" -ArgumentList $username).Host

            $clientId = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"
            $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
            $resourceAppIdUri = "https://graph.microsoft.com"
            $authority = "https://login.microsoftonline.com/$tenant"

            $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority

            # https://msdn.microsoft.com/en-us/library/azure/microsoft.identitymodel.clients.activedirectory.promptbehavior.aspx
            # Change the prompt behaviour to force credentials each time: Auto, Always, Never, RefreshSession
            $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Auto"

            $userId = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier" -ArgumentList ($username, "OptionalDisplayableId")

            $authResult = $authContext.AcquireTokenAsync($resourceAppIdURI, $clientId, $redirectUri, $platformParameters, $userId).Result

            # If the accesstoken is valid then create the authentication header
            if($authResult.AccessToken) {
                # Creating header for Authorization token
                $authHeader = @{
                    'Content-Type' = 'application/json'
                    'Authorization'= "Bearer $($authResult.AccessToken)"
                    'ExpiresOn'    = $authResult.ExpiresOn
                }
        
                $Script:moduleScopeGraphAuthHeader = $authHeader       
                return "Successfully connected to Microsoft Graph! (Tenant ID: $($authResult.TenantId))"
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
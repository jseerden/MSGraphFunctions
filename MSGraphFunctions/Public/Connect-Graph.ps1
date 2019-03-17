function Connect-Graph() {
    <#
        .SYNOPSIS
            Retrieve an Auth Token with Delegated User Permissions
        .DESCRIPTION
            Retrieve an Auth Token for the AzureAD endpoint, using the Active Directory Authentication Library (ADAL) client library,
            which is included in the AzureAD PowerShell Module.

            https://developer.microsoft.com/en-us/graph/docs/concepts/auth_overview
        .PARAMETER Credential
            User Credentials authenticating to Microsoft Graph
        .PARAMETER ClientId
            ClientID of Azure AD Application with permissions for Microsoft Graph
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false)]
        [PSCredential]$Credential,

        [Parameter(Mandatory = $false)]
        [string]$ClientId = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"
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

            if (-not ($Credential)) {
                $Credential = Get-Credential
            }

            $tenant = (New-Object "System.Net.Mail.MailAddress" -ArgumentList $Credential.Username).Host
            $resourceAppIdUri = "https://graph.microsoft.com"
            $authority = "https://login.microsoftonline.com/$tenant"

            $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority

            # https://msdn.microsoft.com/en-us/library/azure/microsoft.identitymodel.clients.activedirectory.promptbehavior.aspx
            # Change the prompt behaviour to force credentials each time: Auto, Always, Never, RefreshSession
            $userCredentials = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.UserPasswordCredential -ArgumentList $Credential.Username, $Credential.Password
            $authResult = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContextIntegratedAuthExtensions]::AcquireTokenAsync($authContext, $resourceAppIdURI, $clientid, $userCredentials).Result
            
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
            Write-Error $_
        }
    }
}
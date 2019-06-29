function Get-GraphAzureADUser() {
    <#
        .SYNOPSIS
            Get Azure AD Users through Microsoft Graph
        .DESCRIPTION
            https://docs.microsoft.com/en-us/graph/api/user-get?view=graph-rest-beta&
            https://docs.microsoft.com/en-us/graph/api/user-list?view=graph-rest-beta
        .PARAMETER Id
            Id or UserPrincipalName of the Azure AD User Object
        .PARAMETER All
            If set to $true, all users in AzureAD will be returned. By default this is limited to 999 (Microsoft Graph Paging is limited to 999 results)
        .PARAMETER ApiVersion
            API version to query
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Id,

        [Parameter(Mandatory = $false)]
        [bool]$All = $false,

        [Parameter(Mandatory = $false)]
        [ValidateSet("v1.0", "beta")]
        [string]$ApiVersion = "beta"
    )

    process {
        try {
            # Check if a Graph Auth Token is available in the Module scope (from the Get-GraphAuthToken function)
            if ($moduleScopeGraphAuthHeader) {
                $authHeader = $moduleScopeGraphAuthHeader
            }
            else {
                Write-Output "Connect to Microsoft Graph using Connect-Graph first."
            }
            
            # Return a specific user
            if ($id) {
                $uri = "https://graph.microsoft.com/$apiVersion/users/$id"
                $query = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method Get -ErrorAction Stop
                return $query
            }
            # Return up to 999 users (limited to 999 in a single query)
            else {
                $uri = "https://graph.microsoft.com/$apiVersion/users?`$top=999"
            }

            $query = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method Get -ErrorAction Stop
            $value = $query.Value
                    
            # Return all users
            if ($all) {
                if ($query.'@odata.nextLink') {
                    do {
                        $query = Invoke-RestMethod -Uri $query.'@odata.nextLink' -Headers $authHeader -Method Get -ErrorAction Stop
                        $value += $query.Value
                    }
                    while ($query.'@odata.nextLink')
                }
            }
        
            return $value
        }
        catch {
            $streamReader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $streamReader.BaseStream.Position = 0
            $streamReader.DiscardBufferedData()
            $responseBody = $streamReader.ReadToEnd()

            Write-Error "Request to $($_.Exception.Response.ResponseUri) failed with HTTP Status $($_.Exception.Response.StatusCode) $($_.Exception.Response.StatusDescription). `nResponse content: `n$responseBody"
        }
    }
}
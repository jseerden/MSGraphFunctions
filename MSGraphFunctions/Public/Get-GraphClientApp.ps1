function Get-GraphClientApp() {
    <#
        .SYNOPSIS
            Get Intune Client Apps through Microsoft Graph
        .DESCRIPTION
            https://docs.microsoft.com/en-us/graph/api/intune-apps-mobileapp-get?view=graph-rest-beta
            https://docs.microsoft.com/en-us/graph/api/intune-apps-mobileapp-list?view=graph-rest-beta
        .PARAMETER SearchString
            DisplayName starts with to search for.
        .PARAMETER Id
            Id of a Client App
        .PARAMETER All
            If set to $true, all device configurations will be returned. By default this is limited to 999 (Microsoft Graph Paging is limited to 999 results)
        .PARAMETER ApiVersion
            API version to query
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$SearchString,

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

            # Return one (GET)
            if ($id) {
                $uri = "https://graph.microsoft.com/$apiVersion/deviceAppManagement/mobileApps/$id"
                $query = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method Get -ErrorAction Stop
                return $query
            }

            if ($searchString) {
                $uri = "https://graph.microsoft.com/$apiVersion/deviceAppManagement/mobileApps?`$filter=startswith(displayName,'$searchString')"
                $query = (Invoke-RestMethod -Uri $uri -Headers $authHeader -Method Get -ErrorAction Stop).value
                return $query
            }

            # Return up to 999 results (limited to 999 in a single query) (LIST)
            $uri = "https://graph.microsoft.com/$apiVersion/deviceAppManagement/mobileApps?`$top=999"
            $query = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method Get -ErrorAction Stop
            $value = $query.Value
                    
            # Return all
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
function Get-GraphAzureADGroup() {
    <#
        .SYNOPSIS
            Get Azure AD Groups through Microsoft Graph
        .DESCRIPTION
            https://developer.microsoft.com/en-us/graph/docs/api-reference/v1.0/api/group_get
            https://developer.microsoft.com/en-us/graph/docs/api-reference/v1.0/api/group_list
        .PARAMETER GroupName
            If exists, a single group matching groupName will be returned
        .PARAMETER All
            If set to $true, all groups in AzureAD will be returned. By default this is limited to 999 (Microsoft Graph Paging is limited to 999 results)
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$GroupName,

        [Parameter(Mandatory = $false)]
        [bool]$All = $false
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
            
            # Return a specific group
            if ($groupName) {
                $uri = "https://graph.microsoft.com/v1.0/groups?%24filter=displayName%20eq%20'$groupName'"
            }
            # Return up to 999 groups (limited to 999 in a single query)
            else {
                $uri = "https://graph.microsoft.com/v1.0/groups?`$top=999"
            }

            $query = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method Get -ErrorAction Stop
            $value = $query.Value
                    
            # Return all groups
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
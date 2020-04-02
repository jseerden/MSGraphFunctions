function Get-GraphDeviceManagementTemplateSettingCategory() {
    <#
        .SYNOPSIS
            Get Intune Device Management Template Setting Categories through Microsoft Graph
        .DESCRIPTION
            https://docs.microsoft.com/en-us/graph/api/intune-deviceintent-devicemanagementtemplate-get?view=graph-rest-beta
            https://docs.microsoft.com/en-us/graph/api/intune-deviceintent-devicemanagementtemplate-list?view=graph-rest-beta
        .PARAMETER Id
            If exists, all device management template setting categories matching the given template id will be returned
        .PARAMETER Category
            If exists, a single device management template setting category matching the given template- and category id will be returned
        .PARAMETER All
            If set to $true, all device management template setting categories will be returned. By default this is limited to 999 (Microsoft Graph Paging is limited to 999 results)
        .PARAMETER ApiVersion
            API version to query
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id,

        [Parameter(Mandatory = $false)]
        [string]$CategoryId,

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
                if ($categoryId) {
                    $uri = "https://graph.microsoft.com/$apiVersion/deviceManagement/templates/$($id)/categories/$($categoryId)"
                    $query = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method Get -ErrorAction Stop
                    return $query
                } else {
                    # Return up to 999 results (limited to 999 in a single query) (LIST)
                    $uri = "https://graph.microsoft.com/$apiVersion/deviceManagement/templates/$($id)/categories?`$top=999"
                    $query = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method Get -ErrorAction Stop
                    $value = $query.Value
                }
            }
                    
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
function Get-GraphDeviceConfiguration() {
    <#
        .SYNOPSIS
            Get Intune Device Configurations through Microsoft Graph
        .DESCRIPTION
            https://docs.microsoft.com/en-us/graph/api/intune-deviceconfig-deviceconfiguration-get?view=graph-rest-1.0
            https://docs.microsoft.com/en-us/graph/api/intune-deviceconfig-deviceconfiguration-list?view=graph-rest-1.0
        .PARAMETER Id
            If exists, a single device configuration matching DeviceConfigurationId will be returned
        .PARAMETER All
            If set to $true, all device configurations will be returned. By default this is limited to 999 (Microsoft Graph Paging is limited to 999 results)
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
        
            # Return one (GET)
            if ($id) {
                $uri = "https://graph.microsoft.com/$apiVersion/deviceManagement/deviceConfigurations/$($id)"
                $query = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method Get -ErrorAction Stop
                return $query
            }

            # Return up to 999 results (limited to 999 in a single query) (LIST)
            $Uri = "https://graph.microsoft.com/$apiVersion/deviceManagement/deviceConfigurations?`$top=999"
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
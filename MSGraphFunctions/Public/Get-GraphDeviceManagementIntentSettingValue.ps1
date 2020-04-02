function Get-GraphDeviceManagementIntentSettingValue() {
    <#
        .SYNOPSIS
            Get Intune Device Management Intent Setting Categories through Microsoft Graph
        .DESCRIPTION
            https://docs.microsoft.com/en-us/graph/api/intune-deviceintent-devicemanagementintentsettingcategory-get?view=graph-rest-beta
            https://docs.microsoft.com/en-us/graph/api/intune-deviceintent-devicemanagementintentsettingcategory-list?view=graph-rest-beta
        .PARAMETER Id
            Device Management Intent Id
        .PARAMETER CategoryId
            Device Management Template Category Id
        .PARAMETER ApiVersion
            API version to query
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id,

        [Parameter(Mandatory = $true)]
        [string]$CategoryId,

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
            
            $uri = "https://graph.microsoft.com/$apiVersion/deviceManagement/intents/$($id)/categories/$($categoryId)/settings?$expand=Microsoft.Graph.DeviceManagementComplexSettingInstance/Value"
            $query = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method Get -ErrorAction Stop
            return $query.Value
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
function Remove-GraphDeviceManagementScript() {
    <#
        .SYNOPSIS
            Delete Intune Device Management Script through Microsoft Graph
        .DESCRIPTION
            https://docs.microsoft.com/en-us/graph/api/intune-devices-devicemanagementscript-delete?view=graph-rest-beta
        .PARAMETER Id
            Id of the Device Management Script to delete
        .PARAMETER ApiVersion
            API version to query
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        [string]$Id,

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

            $uri = "https://graph.microsoft.com/$apiVersion/deviceManagement/deviceManagementScripts/$id"
            $query = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method Delete -ErrorAction Stop

            return $query
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
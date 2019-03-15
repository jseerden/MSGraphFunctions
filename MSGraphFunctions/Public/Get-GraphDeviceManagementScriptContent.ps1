function Get-GraphDeviceManagementScriptContent() {
    <#
        .SYNOPSIS
            Get the content of an Intune Device Management Script through Microsoft Graph
        .DESCRIPTION
            https://docs.microsoft.com/en-us/graph/api/intune-devices-devicemanagementscript-get?view=graph-rest-beta
        .PARAMETER Id
            If exists, the content of a single device management script matching the given id will be returned
        .PARAMETER ApiVersion
            API version to query
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
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
        
            # Return one (GET)
            $uri = "https://graph.microsoft.com/$apiVersion/deviceManagement/deviceManagementScripts/$($id)"
            $query = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method Get -ErrorAction Stop

            # Decode the Base64 encoded Script Content to UTF8 before returning the value
            $value = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($query.scriptContent))

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
function New-GraphDeviceCompliancePolicyAssignment() {
    <#
        .SYNOPSIS
            New Intune Device Compliance Policy Assignment through Microsoft Graph
        .DESCRIPTION
            https://docs.microsoft.com/en-us/graph/api/intune-deviceconfig-devicecompliancepolicy-assign?view=graph-rest-beta
        .PARAMETER Id
            The Id of the Device Management Script we are targeting the assignments to.
        .PARAMETER RequestBody
            Device Management Script Assignment Body as JSON
        .PARAMETER ApiVersion
            API version to query
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [string]$Id,

        [Parameter(Mandatory = $false)]
        [string]$RequestBody,

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

            $uri = "https://graph.microsoft.com/$apiVersion/deviceManagement/deviceCompliancePolicies/$id/assign"
            $uri
            $query = Invoke-RestMethod -Uri $uri -Headers $authHeader -Body $requestBody -Method Post -ContentType "application/json" -ErrorAction Stop

            return $query
        }
        catch {
            Write-Error $_
            $streamReader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $streamReader.BaseStream.Position = 0
            $streamReader.DiscardBufferedData()
            $responseBody = $streamReader.ReadToEnd()

            Write-Error "Request to $($_.Exception.Response.ResponseUri) failed with HTTP Status $($_.Exception.Response.StatusCode) $($_.Exception.Response.StatusDescription). `nResponse content: `n$responseBody"
        }
    }
}
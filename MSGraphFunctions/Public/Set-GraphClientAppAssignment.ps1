function Set-GraphClientAppAssignment() {
    <#
        .SYNOPSIS
            Update Intune Client App Assignments through Microsoft Graph
        .DESCRIPTION
            https://docs.microsoft.com/en-us/graph/api/intune-apps-mobileappassignment-update?view=graph-rest-beta
        .PARAMETER Id
            Id of the application
        .PARAMETER RequestBody
            JSON representation for the mobileAppAssignment object.
        .PARAMETER ApiVersion
            API version to query
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName)]
        [string]$id,

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

            $mobileAppAssignmentId = ($requestBody | ConvertFrom-Json).id

            $uri = "https://graph.microsoft.com/$apiVersion/deviceAppManagement/mobileApps/$id/assignments/$mobileAppAssignmentId"
            $query = Invoke-RestMethod -Uri $uri -Headers $authHeader -Body $requestBody -Method Patch -ErrorAction Stop

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
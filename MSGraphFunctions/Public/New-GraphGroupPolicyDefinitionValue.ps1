function New-GraphGroupPolicyDefinitionValue() {
    <#
        .SYNOPSIS
            Create Intune Group Policy Definition Values through Microsoft Graph
        .DESCRIPTION
            https://docs.microsoft.com/en-us/graph/api/intune-grouppolicy-grouppolicydefinitionvalue-create?view=graph-rest-beta
        .PARAMETER Id
            Id of the group policy configuration associated with the definition value.
        .PARAMETER RequestBody
            Device Group Policy Definition Value Content as JSON
        .PARAMETER ApiVersion
            API version to query
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id,
        
        [Parameter(Mandatory = $true)]
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
            
            $uri = "https://graph.microsoft.com/$apiVersion/deviceManagement/groupPolicyConfigurations/$($id)/definitionValues"
            $query = Invoke-RestMethod -Uri $uri -Headers $authHeader -Body $requestBody -Method Post -ErrorAction Stop

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
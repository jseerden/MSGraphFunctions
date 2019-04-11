function Get-GraphGroupPolicyDefinition() {
    <#
        .SYNOPSIS
            Get Intune Group Policy Definitions through Microsoft Graph
        .DESCRIPTION
            https://docs.microsoft.com/en-us/graph/api/intune-grouppolicy-grouppolicydefinition-get?view=graph-rest-beta
        .PARAMETER GroupPolicyConfigurationId
            The group policy configuration associated with the definition.
        .PARAMETER GroupPolicyDefinitionValueId
            The group policy definition value id associated with the definition.
        .PARAMETER ApiVersion
            API version to query
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$GroupPolicyConfigurationId,

        [Parameter(Mandatory = $true)]
        [string]$GroupPolicyDefinitionValueId,

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
        
            $uri = "https://graph.microsoft.com/$apiVersion/deviceManagement/groupPolicyConfigurations/$($groupPolicyConfigurationId)/definitionValues/$($GroupPolicyDefinitionValueId)/definition"
            $query = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method Get -ErrorAction Stop
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
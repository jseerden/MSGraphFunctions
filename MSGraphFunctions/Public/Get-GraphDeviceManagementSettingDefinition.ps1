function Get-GraphDeviceManagementSettingDefinition() {
    <#
        .SYNOPSIS
            Get Intune Device Management Setting Definitions through Microsoft Graph
        .DESCRIPTION
            https://docs.microsoft.com/en-us/graph/api/intune-deviceintent-devicemanagementabstractcomplexsettingdefinition-get?view=graph-rest-beta
            https://docs.microsoft.com/en-us/graph/api/intune-deviceintent-devicemanagementabstractcomplexsettingdefinition-list?view=graph-rest-beta
        .PARAMETER Id
            If exists, all device management template setting definitions matching the given intent or template id will be returned
        .PARAMETER All
            If set to $true, all device management template setting definitions will be returned. By default this is limited to 999 (Microsoft Graph Paging is limited to 999 results)
        .PARAMETER ApiVersion
            API version to query
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$IntentId,

        [Parameter(Mandatory = $false)]
        [string]$TemplateId,

        [Parameter(Mandatory = $true)]
        [string]$CategoryId,

        [Parameter(Mandatory = $false)]
        [string]$SettingsDefinitionId,

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

            if ($templateId -and $intentId) {
                return "Please specify either an Intent Id or Template Id."
            }
            
            # Return one (GET)
            if ($intentId) {
                if ($settingsDefinitionId) {
                    $uri = "https://graph.microsoft.com/$apiVersion/deviceManagement/intents/$($intentId)/categories/$($categoryId)/settingDefinitions/$($settingsDefinitionId)"
                    $query = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method Get -ErrorAction Stop
                    return $query
                } else {
                    $uri = "https://graph.microsoft.com/$apiVersion/deviceManagement/intents/$($intentId)/categories/$($categoryId)/settingDefinitions"
                    $query = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method Get -ErrorAction Stop
                    $value = $query.Value
                }
            } elseif ($templateId) {
                if ($settingsDefinitionId) {
                    $uri = "https://graph.microsoft.com/$apiVersion/deviceManagement/templates/$($templateId)/categories/$($categoryId)/settingDefinitions/$($settingsDefinitionId)"
                    $query = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method Get -ErrorAction Stop
                    return $query
                } else {
                    $uri = "https://graph.microsoft.com/$apiVersion/deviceManagement/templates/$($templateId)/categories/$($categoryId)/settingDefinitions"
                    $query = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method Get -ErrorAction Stop
                    $value = $query.Value
                }
            }    

            if ($query.'@odata.nextLink') {
                do {
                    $query = Invoke-RestMethod -Uri $query.'@odata.nextLink' -Headers $authHeader -Method Get -ErrorAction Stop
                    $value += $query.Value
                }
                while ($query.'@odata.nextLink')
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
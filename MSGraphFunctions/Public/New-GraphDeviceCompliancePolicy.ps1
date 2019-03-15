function New-GraphDeviceCompliancePolicy() {
    <#
        .SYNOPSIS
            New Intune Device Compliance Policy through Microsoft Graph
        .DESCRIPTION
            https://docs.microsoft.com/en-us/graph/api/intune-deviceconfig-windows10compliancepolicy-create?view=graph-rest-beta
        .PARAMETER RequestBody
            Device Compliance Content as JSON
        .PARAMETER ApiVersion
            API version to query
    #>
    [cmdletbinding()]
    param(
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

            $requestBodyObject = $requestBody | ConvertFrom-Json
            $requestBody = $requestBodyObject | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime | ConvertTo-Json

            # If missing, adds a default required block scheduled action to the compliance policy request body, as this value is not returned when retrieving compliance policies.
            $requestBodyObject = $requestBody | ConvertFrom-Json
            if (-not ($requestBodyObject.scheduledActionsForRule)) {
                $scheduledActionsForRule = @(
                    @{
                        ruleName = "PasswordRequired"
                        scheduledActionConfigurations = @(
                            @{
                                actionType = "block"
                                gracePeriodHours = 0
                                notificationTemplateId = ""
                            }
                        )
                    }
                )
                $requestBodyObject | Add-Member -NotePropertyName scheduledActionsForRule -NotePropertyValue $scheduledActionsForRule
                
                # Update the request body reflecting the changes
                $requestBody = $requestBodyObject | ConvertTo-Json -Depth 4
            }

            $uri = "https://graph.microsoft.com/$apiVersion/deviceManagement/deviceCompliancePolicies"
            $query = Invoke-RestMethod -Uri $uri -Headers $authHeader -Body $requestBody -Method Post -ErrorAction Stop

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
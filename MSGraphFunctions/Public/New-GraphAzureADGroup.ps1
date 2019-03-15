function New-GraphAzureADGroup() {
    <#
        .SYNOPSIS
            Create an Azure AD Group through Microsoft Graph.
        .DESCRIPTION
            https://developer.microsoft.com/en-us/graph/docs/api-reference/v1.0/api/group_post_groups
        .PARAMETER DisplayName
            The name to display in the address book for the group.
        .PARAMETER MailEnabled
            Set to true for mail-enabled groups. Set this to true if creating an Office 365 Group. Set this to false if creating dynamic or security group.
        .PARAMETER MailNickname
            The mail alias for the group.
        .PARAMETER SecurityEnabled
            Set to true for security-enabled groups. Set this to true if creating a dynamic or security group. Set this to false if creating an Office 365 group. Required.
        .PARAMETER Owners
            This property represents the owners for the group at creation time.
        .PARAMETER Members
            This property represents the members for the group at creation time.
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DisplayName,

        [Parameter(Mandatory = $true)]
        [bool]$MailEnabled,

        [Parameter(Mandatory = $true)]
        [string]$MailNickname,

        [Parameter(Mandatory = $true)]
        [bool]$SecurityEnabled,

        [Parameter(Mandatory = $false)]
        [array]$Owners,

        [Parameter(Mandatory = $false)]
        [array]$Members
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

            $uri = "https://graph.microsoft.com/v1.0/groups"
        
            # Mandatory parameters
            $body = @{
                'displayName'     = $displayName
                'mailEnabled'     = $mailEnabled
                'mailNickname'    = $mailNickname
                'securityEnabled' = $securityEnabled
            }

            # Optional parameters
            if ($owners) {
                $body.add('owners', $owners)
            }

            if ($members) {
                $body.add('members', $members)
            }

            $bodyAsJson = $body | ConvertTo-Json
        
            # Encode as UTF-8 to support accented characters in Display Names.
            $query = Invoke-RestMethod -Uri $uri -Headers $authHeader -Body ([System.Text.Encoding]::UTF8.GetBytes($bodyAsJson)) -Method POST -ErrorAction Stop
            
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
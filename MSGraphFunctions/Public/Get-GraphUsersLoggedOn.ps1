function Get-GraphUsersLoggedOn() {
    <#
        .SYNOPSIS
            Get Intune Managed Device Users Logged On through Microsoft Graph
        .DESCRIPTION
            https://docs.microsoft.com/en-us/graph/api/intune-devices-manageddevice-get?view=graph-rest-beta
            https://docs.microsoft.com/en-us/graph/api/resources/intune-devices-loggedonuser?view=graph-rest-beta
        .PARAMETER Id
            The Id of the Managed Device (Get-GraphManagedDevice)
        .PARAMETER ApiVersion
            API version to query
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Id
    )

    # DeviceNames for ManagedDevices may be duplicate. Do not filter on -id to prevent Bad Requests.
    $managedDevice = Get-GraphManagedDevice -Id $id
    $usersLoggedOn = $managedDevice | Select-Object -ExpandProperty usersLoggedOn

    if ($usersLoggedOn) {
        foreach ($user in $usersLoggedOn) { 
            $userLoggedOn = Get-GraphAzureADUser -Id $user.userId
            New-Object PSCustomObject -Property @{
                'deviceName'  = $managedDevice.deviceName
                'id' = $managedDevice.id
                'userDisplayName' = $userLoggedOn.displayName
                'userPrincipalName' = $userLoggedOn.userPrincipalname
                'lastLogonDateTime' = Get-Date -Date $user.lastLogonDateTime
            }
        }
    }
    else {
        Write-Output "$($managedDevice.deviceName) ($($managedDevice.id)) - No users have logged on to this device."
    }
}

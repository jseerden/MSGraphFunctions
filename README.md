# MSGraphFunctions

![PowerShell Gallery](https://img.shields.io/powershellgallery/v/MSGraphFunctions.svg?label=PSGallery%20Version&logo=PowerShell&style=flat-square)
![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/MSGraphFunctions.svg?label=PSGallery%20Downloads&logo=PowerShell&style=flat-square)

PowerShell Functions to query the [Microsoft Graph API](https://developer.microsoft.com/en-us/graph).

Note that these functions run on the Microsoft Graph beta endpoint by default. For version 1, specify the -apiVersion "v1.0" switch.

## Installing MSGraphFunctions

```powershell
# Install MSGraphFunctions from the PowerShell Gallery
Install-Module -Name MSGraphFunctions
```

## Prerequisites
- Requires Azure AD Module installed.

### Authenticate to Microsoft Graph
```powershell
Import-Module MSGraphFunctions

# Authenticate for the first time and grant permissions for the "Microsoft Intune PowerShell" Enterprise Application. (Interactive Authentication (Supports MFA))
Connect-Graph -AdminConsent $true

# Interactive Authentication (Supports MFA)
Connect-Graph

# Non Interactive Authentication (Supports Automation Goals)
$Credential = Get-Credential
Connect-Graph -Credential $Credential
```

## Examples

### Example 01 - List all Intune Device Compliance Policies
```powershell
$compliancePolicies = Get-GraphDeviceCompliancePolicy
$compliancePolicies
```

### Example 02 - Duplicate an Intune Device Configuration Policy
```powershell
$deviceConfiguration = Get-GraphDeviceConfiguration -id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
$requestBody = $deviceConfiguration | ConvertTo-Json

New-GraphDeviceConfiguration -requestBody $requestBody
```

### Example 03 - Retrieve PowerShell Script Content
```powershell
# Content of a Single Script
Get-GraphDeviceManagementScript -Id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx | Get-GraphDeviceManagementScriptContent

# Or
Get-GraphDeviceManagementScriptContent -Id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# Output PowerShell Script Content of all Uploaded Scripts
Get-GraphDeviceManagementScript | Get-GraphDeviceManagementScriptContent
```

### Example 04 - Delete an Intune Device Compliance Policy
```powershell
Get-GraphDeviceComplaincePolicy -Id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx | Remove-GraphDeviceComplaincePolicy
```

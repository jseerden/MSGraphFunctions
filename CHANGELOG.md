# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.4.0] - 2019-6-29
### Added
- Get-GraphAzureADUser Function
- Get-GraphUsersLoggedOn Function

### Changed
- Get-GraphAzureADGroup Function: API endpoint parameter added. Defaults to beta.

## [2.3.0] - 2019-4-12
### Added
- Connect-Graph now supports interactive authentication by default to trigger the Enterprise Application creation of "Microsoft Intune PowerShell" and supports the usage of MFA. Non-interactive authentication works as before by passing a PSCredential object to the `Credential` parameter.

## [2.2.0] - 2019-04-11
### Added
- Get-GraphGroupPolicyConfiguration Function
- Get-GraphGroupPolicyConfigurationAssignment Function
- Get-GraphGroupPolicyDefinition Function
- Get-GraphGroupPolicyDefinitionValue Function
- Get-GraphGroupPolicyPresentationValue Function
- New-GraphGroupPolicyConfiguration Function
- New-GraphGroupPolicyConfigurationAssignement Function
- New-GraphGroupPolicyDefinitionValue Function
- Remove-GraphGroupPolicyConfiguration Function

## [2.1.0] - 2019-03-26
### Added
- Get-GraphManagedDevice Function to retrieve Intune Managed Device objects
- Get-GraphWindowsAutopilotDeviceIdentity Function to retrieve Windows Autopilot Device objects

## [2.0.1] - 2019-03-17
### Added
- Set Credential Parameter mandatory

## [2.0.0] - 2019-03-17
### Added
- MSGraphFunctions now supports non-interactive authentication to Microsoft Graph using Delegated permissions

### Changed
- BREAKING: Connect-Graph now requires a $Credential parameter of type PSCredential

## [1.0.0] - 2019-03-15
### Added
- PowerShell module initial release
- CHANGELOG file
- README file
- LICENSE
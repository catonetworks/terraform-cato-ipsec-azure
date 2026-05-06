# Changelog

## 0.1.5 (2026-05-06)

### Changed
- Updated AzureRM to 4.71.0

## 0.1.4 (2026-04-14)

### Features
- Updated version of provider adding in lastest SDK with updated ENUM values for accounSnapshot and license
- Updated VPNGW to support zones required by Azure
- Updated the siteLocation file to resolve all cities, statecodes localy without needing data source dependency 
- Updated readme

## 0.1.3 (2025-07-23)

### Features 
- Update Site Location to include Poland
- Update Readme Example

## 0.1.3 (2025-07-23)

### Features 
- Update Site Location to include Poland
- Update Readme Example

## 0.1.2 (2025-07-17)

### Features 
- Fix Malformed SiteLocation.tf

## 0.1.1 (2025-07-17)

## Features 
 - Updated to dynamically pull site location information from Azure Location 
 - Version locked Cato provider to v0.0.30 or greater
 - Version locked Terraform to v1.5 or greater

## 0.1.0 (2025-06-10)

### Features
- Refactor Module to Support both BGP and Non-BGP based routing 
- Adjusted API Calls to Enable the configuration of all IPSec Attributes 
- Updated API Call execution from null_resource to terraform_data enabling replacement based on changes to parameters
- Enable conditional creation of VNG Vnet and VNG Subnets
- Updated Readme to reflect changes 
- Updated Outputs to reflect changes and added additional outputs 
- Added Data Call to Cato API to get Cato IP ID 
- Added Locals to simplify resource naming
- Adjusted variable names to simplify understanding of which variable is for which environment 
- Added CSP Tag handling to enable resource tagging 
- Enabled Active/Active Virtual Network Gateway to ensure redundancy and resiliency 
- Added Variables for BGP and Non-BGP to support new functions

## 0.0.11 (2025-05-15)

### Features
- Fixed variable name for ipsec-site

## 0.0.10 (2025-05-13)

### Features
- Adding variables for cato_token, account_id and baseurl for custom calls
- Updating README to reflect correct variables
- Corrected license site syntax

## 0.0.4 (2025-05-08)

### Features
- Added optional license resource and inputs used for commercial site deployments

## 0.0.2 (2024-11-19)

### Features
- Initial commit

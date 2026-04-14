locals {
  # Check if user provided site_location (any field is non-null)
  use_user_location = (
    var.site_location.city != null ||
    var.site_location.country_code != null ||
    var.site_location.state_code != null ||
    var.site_location.timezone != null
  )

  locationstr = lower(replace(var.az_location, " ", ""))

  # Manual mapping of Azure regions to their cities and countries
  # Since Azure doesn't provide city/country in the API, we create our own mapping
  # Note: Only US, AU, IN, BR state codes work - all others must be null
  region_to_site_location = {
    # North America - United States
    "eastus"         = { city = "Ashburn", country_code = "US", state_code = "US-VA", timezone = "America/New_York" }
    "eastus2"        = { city = "Ashburn", country_code = "US", state_code = "US-VA", timezone = "America/New_York" }
    "centralus"      = { city = "Des Moines", country_code = "US", state_code = "US-IA", timezone = "America/Chicago" }
    "northcentralus" = { city = "Chicago", country_code = "US", state_code = "US-IL", timezone = "America/Chicago" }
    "southcentralus" = { city = "San Antonio", country_code = "US", state_code = "US-TX", timezone = "America/Chicago" }
    "westcentralus"  = { city = "Cheyenne", country_code = "US", state_code = "US-WY", timezone = "America/Denver" }
    "westus"         = { city = "San Francisco", country_code = "US", state_code = "US-CA", timezone = "America/Los_Angeles" }
    "westus2"        = { city = "Seattle", country_code = "US", state_code = "US-WA", timezone = "America/Los_Angeles" }
    "westus3"        = { city = "Phoenix", country_code = "US", state_code = "US-AZ", timezone = "America/Phoenix" }

    # North America - Canada
    "canadacentral" = { city = "Toronto", country_code = "CA", state_code = null, timezone = "America/Toronto" }
    "canadaeast"    = { city = "Montréal", country_code = "CA", state_code = null, timezone = "America/Toronto" }

    # Europe
    "northeurope"        = { city = "Dublin", country_code = "IE", state_code = null, timezone = "Europe/Dublin" }
    "westeurope"         = { city = "Brussels", country_code = "BE", state_code = null, timezone = "Europe/Brussels" }
    "francecentral"      = { city = "Paris", country_code = "FR", state_code = null, timezone = "Europe/Paris" }
    "francesouth"        = { city = "Marseille", country_code = "FR", state_code = null, timezone = "Europe/Paris" }
    "germanywestcentral" = { city = "Frankfurt am Main", country_code = "DE", state_code = null, timezone = "Europe/Berlin" }
    "germanynorth"       = { city = "Berlin", country_code = "DE", state_code = null, timezone = "Europe/Berlin" }
    "norwayeast"         = { city = "Oslo", country_code = "NO", state_code = null, timezone = "Europe/Oslo" }
    "norwaywest"         = { city = "Oslo", country_code = "NO", state_code = null, timezone = "Europe/Oslo" }
    "swedencentral"      = { city = "Stockholm", country_code = "SE", state_code = null, timezone = "Europe/Stockholm" }
    "switzerlandnorth"   = { city = "Zürich", country_code = "CH", state_code = null, timezone = "Europe/Zurich" }
    "switzerlandwest"    = { city = "Genève", country_code = "CH", state_code = null, timezone = "Europe/Zurich" }
    "uksouth"            = { city = "London", country_code = "GB", state_code = null, timezone = "Europe/London" }
    "ukwest"             = { city = "Cardiff", country_code = "GB", state_code = null, timezone = "Europe/London" }
    "polandcentral"      = { city = "Warsaw", country_code = "PL", state_code = null, timezone = "Europe/Warsaw" }

    # Asia Pacific
    "eastasia"        = { city = "Hong Kong", country_code = "HK", state_code = null, timezone = "Asia/Hong_Kong" }
    "southeastasia"   = { city = "Singapore", country_code = "SG", state_code = null, timezone = "Asia/Singapore" }
    "centralindia"    = { city = "Pune", country_code = "IN", state_code = "IN-MH", timezone = "Asia/Kolkata" }
    "southindia"      = { city = "Chennai", country_code = "IN", state_code = "IN-TN", timezone = "Asia/Kolkata" }
    "westindia"       = { city = "Mumbai", country_code = "IN", state_code = "IN-MH", timezone = "Asia/Kolkata" }
    "jioindiacentral" = { city = "Jamnagar", country_code = "IN", state_code = "IN-GJ", timezone = "Asia/Kolkata" }
    "jioindiawest"    = { city = "Jamnagar", country_code = "IN", state_code = "IN-GJ", timezone = "Asia/Kolkata" }
    "japaneast"       = { city = "Tokyo", country_code = "JP", state_code = null, timezone = "Asia/Tokyo" }
    "japanwest"       = { city = "Osaka", country_code = "JP", state_code = null, timezone = "Asia/Tokyo" }
    "koreacentral"    = { city = "Seoul", country_code = "KR", state_code = null, timezone = "Asia/Seoul" }
    "koreasouth"      = { city = "Busan", country_code = "KR", state_code = null, timezone = "Asia/Seoul" }

    # Asia Pacific - Australia
    "australiaeast"      = { city = "Sydney", country_code = "AU", state_code = "AU-NSW", timezone = "Australia/Sydney" }
    "australiacentral"   = { city = "Canberra", country_code = "AU", state_code = "AU-ACT", timezone = "Australia/Sydney" }
    "australiacentral2"  = { city = "Canberra", country_code = "AU", state_code = "AU-ACT", timezone = "Australia/Sydney" }
    "australiasoutheast" = { city = "Melbourne", country_code = "AU", state_code = "AU-VIC", timezone = "Australia/Melbourne" }

    # Middle East
    "uaenorth"     = { city = "Dubai", country_code = "AE", state_code = null, timezone = "Asia/Dubai" }
    "uaecentral"   = { city = "Abu Dhabi", country_code = "AE", state_code = null, timezone = "Asia/Dubai" }
    "qatarcentral" = { city = "Doha", country_code = "QA", state_code = null, timezone = "Asia/Qatar" }

    # Africa
    "southafricanorth" = { city = "Johannesburg", country_code = "ZA", state_code = null, timezone = "Africa/Johannesburg" }
    "southafricawest"  = { city = "Cape Town", country_code = "ZA", state_code = null, timezone = "Africa/Johannesburg" }

    # South America
    "brazilsouth" = { city = "São Paulo", country_code = "BR", state_code = "BR-SP", timezone = "UTC-3" }
  }

  # Use user-provided location if any field is set, otherwise use hardcoded mapping
  cur_site_location = local.use_user_location ? var.site_location : local.region_to_site_location[local.locationstr]
}

output "site_location" {
  description = "The resolved site location from Azure region mapping"
  value       = local.cur_site_location
}

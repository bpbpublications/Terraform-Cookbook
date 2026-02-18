# Standard tags that environments can import via locals or module inputs.
locals {
  standard_tags = {
    Application = "CookbookSample"
    Owner       = "PlatformTeam"
    ManagedBy   = "Terraform"
  }
}

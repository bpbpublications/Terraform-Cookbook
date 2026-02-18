locals {
  # Prefix every resource with env to avoid name collisions
  prefix = "${var.env}-web"

  # Tags applied everywhere
  common_tags = {
    environment = var.env
    owner       = "TerraformCookbook"
  }
}

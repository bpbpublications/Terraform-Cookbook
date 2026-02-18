locals {
  name_suffix = "${var.project}-${var.environment}"

  # Standard tags across all resources
  tags = {
    project     = var.project
    environment = var.environment
    owner       = "platform-engineering"
  }
}

# A short random suffix to keep names unique
resource "random_string" "suffix" {
  length  = 4
  lower   = true
  upper   = false
  numeric = true
  special = false
}

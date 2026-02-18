// file: main.tf
terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.57" // or newer
    }
  }
}

provider "tfe" {
  hostname = "app.terraform.io"
  // Authenticate using your TFE token through environment variable TFE_TOKEN
}

// Create a Sentinel policy object in your organization
resource "tfe_policy" "s3_versioning" {
  organization = var.organization
  name         = "s3-versioning-required"
  kind         = "sentinel"
  description  = "Require versioning on all S3 buckets"

  // Provide policy source from a local file
  // Some provider versions use 'policy' attribute for inline text
  // or 'source' to read from a file depending on version
  policy = file("${path.module}/policies/s3-versioning-required.sentinel")
}

// Create a policy set and include the policy
resource "tfe_policy_set" "team_guardrails" {
  name          = "team-guardrails"
  description   = "Guardrails for S3 versioning"
  organization  = var.organization
  kind          = "sentinel"     // or "opa" for OPA policy sets
  policy_ids    = [tfe_policy.s3_versioning.id]
  // Either attach directly via workspace_ids here
  // or use the dedicated attachment resource shown below
}

// Attach the policy set to one or more workspaces
// Use this resource instead of workspace_ids on tfe_policy_set
// to avoid conflicting attachments management
resource "tfe_workspace_policy_set" "attach" {
  workspace_id = var.workspace_id
  policy_set_id = tfe_policy_set.team_guardrails.id
}

variable "organization" {}
variable "workspace_id" {}

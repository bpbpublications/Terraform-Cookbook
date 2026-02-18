data "external" "deployment_config" {
  program = ["python", "${path.module}/config-fetcher.py"]
}

# Turn the JSON text back into Terraform lists
locals {
  region       = data.external.deployment_config.result["region"]
  environments = jsondecode(data.external.deployment_config.result["environments"])
  allowed_ips  = jsondecode(data.external.deployment_config.result["allowed_ips"])
}

output "region" {
  value = local.region
}

output "environments" {
  value = local.environments
}

output "allowed_ips" {
  value = local.allowed_ips
}

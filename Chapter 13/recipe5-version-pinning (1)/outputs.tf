# outputs.tf
output "hello" {
  description = "Confirms providers resolved and plan/apply succeeded"
  value       = "Hello from Terraform ${terraform.version}, rand=${random_string.suffix.result}"
}

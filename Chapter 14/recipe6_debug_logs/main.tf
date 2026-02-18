resource "random_string" "sample" {
  length  = 8
  upper   = false
  lower   = true
  special = false
  numeric = true
}

output "sample" {
  value = random_string.sample.result
}

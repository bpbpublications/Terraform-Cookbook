# null_resource runs a local PowerShell script after the plan is applied.
resource "null_resource" "smoke_test" {
  provisioner "local-exec" {
    command = "powershell -ExecutionPolicy Bypass -File ${path.module}/smoke-test.ps1 ${var.endpoint_url}"
  }
}
resource "null_resource" "notify" {
  provisioner "local-exec" {
    # This will always resolve to the absolute folder where this module lives
    command = "powershell -NoProfile -ExecutionPolicy Bypass -File \"${path.module}\\notify.ps1\""
  }
}

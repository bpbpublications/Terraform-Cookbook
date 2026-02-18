// file: sentinel.hcl
policy "s3-versioning-required" {
  source            = "./policies/s3-versioning-required.sentinel"
  enforcement_level = "hard-mandatory"
}

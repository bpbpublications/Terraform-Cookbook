policy "tags-policy" {
  source            = "./tags-policy.sentinel"  # Location of policy
  enforcement_level = "hard-mandatory"          # Block applies if fail
}

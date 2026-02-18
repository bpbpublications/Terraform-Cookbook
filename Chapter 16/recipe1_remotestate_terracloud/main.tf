terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "your-organization"
    workspaces {
      name = "your-workspace-name"
    }
  }
}
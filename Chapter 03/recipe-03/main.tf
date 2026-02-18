terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "<your org>"
    workspaces {
	      name = "chapter3-r3"
	    }
	  }
	}

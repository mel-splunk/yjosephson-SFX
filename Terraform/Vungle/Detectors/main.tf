provider "signalfx" {
  api_url = "https://api.us2.signalfx.com"
}

terraform {
  required_version = ">= 0.12"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "vungle-sfx"

    workspaces {
      name = "detectors"
    }
  }
}

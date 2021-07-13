terraform {
  required_providers {
    aci = {
      source  = "CiscoDevNet/aci"
      version = "0.7.0"
    }
  }
  required_version = ">=0.13.4"
}

provider "aci" {
  username = var.aci_user
  password = var.aci_pw
  url      = var.aci_url
  insecure = var.aci_https
}

resource "aci_tenant" "my_tenant" {
  name = "MyFirstTenant"
  # description = "Created by terraform"
}
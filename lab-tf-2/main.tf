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
  username = var.secret.user
  password = var.secret.pw
  url      = var.secret.url
  insecure = var.secret.insecure
}

# resource "aci_vlan_pool" "example" {
#   name       = "example"
#   alloc_mode = "dynamic"
#   annotation = "orchestrator:terraform"
#   name_alias = "example"
# }

# resource "aci_vlan_pool" "example" {
#   name       = var.vlan_pools.DEMO_VLAN.vlan_name
#   alloc_mode = var.vlan_pools.DEMO_VLAN.alloc_mode
#   annotation = contains(keys(var.vlan_pools.DEMO_VLAN), "annotation") ? var.vlan_pools.DEMO_VLAN.annotation : null
#   name_alias = contains(keys(var.vlan_pools.DEMO_VLAN), "name_alias") ? var.vlan_pools.DEMO_VLAN.name_alias : null
# }

# resource "aci_vlan_pool" "example" {
#   for_each   = var.vlan_pools
#   name       = each.value.vlan_name
#   alloc_mode = each.value.alloc_mode
#   annotation = contains(keys(each.value), "annotation") ? each.value.annotation : null
#   name_alias = contains(keys(each.value), "name_alias") ? each.value.name_alias : null
# }
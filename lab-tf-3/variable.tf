variable "secret" {
  type = map(any)
  default = {
    url      = ""
    user     = ""
    pw       = ""
    insecure = false
  }
  sensitive = true
}

variable "vlan_pools" {
  type    = map(any)
  default = {}
}
variable "vlan_pools_ranges" {
  type    = map(any)
  default = {}
}
variable "physical_domains" {
  type    = map(any)
  default = {}
}
variable "cdp_policies" {
  type    = map(any)
  default = {}
}
variable "lldp_policies" {
  type    = map(any)
  default = {}
}
variable "lacp_policies" {
  type    = map(any)
  default = {}
}
variable "link_level_policies" {
  type    = map(any)
  default = {}
}
variable "aeps" {
  type    = map(any)
  default = {}
}
variable "leaf_access_policy_groups" {
  type    = map(any)
  default = {}
}
variable "leaf_interface_profiles" {
  type    = map(any)
  default = {}
}
variable "access_port_selectors" {
  type    = map(any)
  default = {}
}
variable "access_groups" {
  type    = map(any)
  default = {}
}
variable "leaf_profiles" {
  type    = map(any)
  default = {}
}
variable "leaf_selectors" {
  type    = map(any)
  default = {}
}
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

# variable "vlan_pools" {
#   type    = map(any)
#   default = {}
# }
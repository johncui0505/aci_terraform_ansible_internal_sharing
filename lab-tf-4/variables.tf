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

variable "tenants" {}

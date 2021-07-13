variable "secret" {
  type = map(any)
  default = {
    url  = ""
    user = ""
    pw   = ""
  }
  sensitive = true
}

variable "tenant" {}
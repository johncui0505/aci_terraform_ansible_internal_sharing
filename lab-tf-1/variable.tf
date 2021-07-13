variable "aci_url" {
  type = string
}

variable "aci_user" {
  type = string
}

variable "aci_pw" {
  type      = string
  sensitive = true
}

variable "aci_https" {
  type    = bool
  default = true
}
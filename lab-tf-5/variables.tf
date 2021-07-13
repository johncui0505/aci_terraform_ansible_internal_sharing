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

variable "epg_static_paths" {
  type = map(object(
    {
      tenant               = string
      ap                   = string
      epg                  = string
      pod                  = string
      node                 = string
      port                 = string
      encap                = string
      deployment_immediacy = string
      mode                 = string
    })
  )
  default = {}
}
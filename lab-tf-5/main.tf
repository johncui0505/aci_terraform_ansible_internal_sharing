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
  insecure = true
}

resource "aci_epg_to_static_path" "aci_static_path" {
  for_each           = var.epg_static_paths
  application_epg_dn = format("uni/tn-%s/ap-%s/epg-%s", each.value.tenant, each.value.ap, each.value.epg)
  tdn                = format("topology/pod-%s/paths-%s/pathep-[%s]", each.value.pod, each.value.node, each.value.port)
  encap              = each.value.encap
  instr_imedcy       = each.value.deployment_immediacy
  mode               = each.value.mode
}
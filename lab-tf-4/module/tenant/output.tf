output "tenant" {
  value = aci_tenant.aci_tenant.id
}

output "vrf" {
  value = [for vrf in aci_vrf.aci_vrf : vrf.id]
}

output "bd" {
  value = [for bd in aci_bridge_domain.aci_bds : bd.id]
}

output "subnet" {
  value = [for subnet in aci_subnet.aci_subnets : subnet.id]
}

output "ap" {
  value = [for ap in aci_application_profile.aci_app_profile : ap.id]
}

output "epg" {
  value = [for epg in aci_application_epg.aci_epgs : epg.id]
}

output "contract" {
  value = [for cont in aci_contract.aci_contracts : cont.id]
}

output "epg_to_domain" {
  value = [for item in aci_epg_to_domain.aci_epg_domain : item.id]
}
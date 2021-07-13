terraform {
  required_providers {
    aci = {
      source  = "CiscoDevNet/aci"
      version = "0.7.0"
    }
  }
  required_version = ">=0.13.4"
}

locals {
  tenant            = var.tenant.tenant
  vrfs              = contains(keys(var.tenant), "vrfs") ? var.tenant.vrfs : {}
  bridge_domains    = contains(keys(var.tenant), "bridge_domains") ? var.tenant.bridge_domains : {}
  subnets           = contains(keys(var.tenant), "subnets") ? var.tenant.subnets : {}
  app_profiles      = contains(keys(var.tenant), "app_profiles") ? var.tenant.app_profiles : {}
  epgs              = contains(keys(var.tenant), "epgs") ? var.tenant.epgs : {}
  filters           = contains(keys(var.tenant), "filters") ? var.tenant.filters : {}
  filter_subjects   = contains(keys(var.tenant), "filter_subjects") ? var.tenant.filter_subjects : {}
  filter_entries    = contains(keys(var.tenant), "filter_entries") ? var.tenant.filter_entries : {}
  contracts         = contains(keys(var.tenant), "contracts") ? var.tenant.contracts : {}
  contract_bindings = contains(keys(var.tenant), "contract_bindings") ? var.tenant.contract_bindings : {}
  epg_to_domains    = contains(keys(var.tenant), "epg_to_domains") ? var.tenant.epg_to_domains : {}
}

resource "aci_tenant" "aci_tenant" {
  name = local.tenant.name
}

resource "aci_vrf" "aci_vrf" {
  for_each    = local.vrfs
  tenant_dn   = aci_tenant.aci_tenant.id
  name        = each.value.name
  pc_enf_dir  = contains(keys(each.value), "pc_enf_dir") ? each.value.pc_enf_dir : null
  pc_enf_pref = contains(keys(each.value), "pc_enf_pref") ? each.value.pc_enf_pref : null
}

resource "aci_bridge_domain" "aci_bds" {
  for_each           = local.bridge_domains
  tenant_dn          = aci_tenant.aci_tenant.id
  name               = each.value.name
  relation_fv_rs_ctx = aci_vrf.aci_vrf[each.value.ref_vrf].id
}

resource "aci_subnet" "aci_subnets" {
  for_each  = local.subnets
  parent_dn = aci_bridge_domain.aci_bds[each.value.ref_bd].id
  ip        = each.value.ip
  scope     = contains(keys(each.value), "scope") ? each.value.scope : null
}

resource "aci_application_profile" "aci_app_profile" {
  for_each  = local.app_profiles
  tenant_dn = aci_tenant.aci_tenant.id
  name      = each.value.name
}

resource "aci_application_epg" "aci_epgs" {
  for_each               = local.epgs
  application_profile_dn = aci_application_profile.aci_app_profile[each.value.ref_ap].id
  name                   = each.value.name
  relation_fv_rs_bd      = aci_bridge_domain.aci_bds[each.value.ref_bd].id
}

resource "aci_filter" "aci_filters" {
  for_each  = local.filters
  tenant_dn = aci_tenant.aci_tenant.id
  name      = each.value.name
}

resource "aci_filter_entry" "aci_filter_entries" {
  for_each    = local.filter_entries
  filter_dn   = aci_filter.aci_filters[each.value.ref_filter].id
  name        = each.value.name
  d_from_port = each.value.dest_from_port
  d_to_port   = each.value.dest_to_port
  ether_t     = each.value.ether_type
  prot        = each.value.protocol
}

resource "aci_contract" "aci_contracts" {
  for_each  = local.contracts
  tenant_dn = aci_tenant.aci_tenant.id
  name      = each.value.name
}

resource "aci_contract_subject" "aci_contract_subjects" {
  for_each                     = local.filter_subjects
  contract_dn                  = aci_contract.aci_contracts[each.value.ref_contract].id
  name                         = each.value.name
  relation_vz_rs_subj_filt_att = [for idx in each.value.ref_filter : aci_filter.aci_filters[idx].id]
}

resource "aci_epg_to_contract" "aci_epg_contract" {
  for_each           = local.contract_bindings
  application_epg_dn = aci_application_epg.aci_epgs[each.value.ref_epg].id
  contract_dn        = aci_contract.aci_contracts[each.value.ref_contract].id
  contract_type      = each.value.contract_type
}

resource "aci_epg_to_domain" "aci_epg_domain" {
  for_each           = local.epg_to_domains
  application_epg_dn = aci_application_epg.aci_epgs[each.value.ref_epg].id
  tdn                = each.value.aci_domain_dn
}
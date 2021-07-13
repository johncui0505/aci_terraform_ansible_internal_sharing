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

## --------------------------- task 1 - VLAN Pool
# resource "aci_vlan_pool" "aci_vlan_pools" {
#   for_each   = var.vlan_pools
#   name       = each.value.vlan_name
#   alloc_mode = contains(keys(each.value), "alloc_mode") ? each.value.alloc_mode : null
#   annotation = contains(keys(each.value), "annotation") ? each.value.annotation : null
# }

# resource "aci_ranges" "aci_vlan_pools_ranges" {
#   for_each     = var.vlan_pools_ranges
#   vlan_pool_dn = aci_vlan_pool.aci_vlan_pools[each.value.vlan_pool_name].id
#   from         = contains(keys(each.value), "from") ? each.value.from : null
#   to           = contains(keys(each.value), "to") ? each.value.to : null
#   alloc_mode   = contains(keys(each.value), "alloc_mode") ? each.value.alloc_mode : null
#   role         = contains(keys(each.value), "role") ? each.value.role : null
# }

# ## --------------------------- task 2 - ACI Domain
# resource "aci_physical_domain" "aci_physical_domains" {
#   for_each                  = var.physical_domains
#   name                      = each.value.name
#   relation_infra_rs_vlan_ns = contains(keys(each.value), "vlan_pool") ? aci_vlan_pool.aci_vlan_pools[each.value.vlan_pool].id : null
# }

# ## --------------------------- task 3 - AEP
# resource "aci_attachable_access_entity_profile" "aci_aeps" {
#   for_each                = var.aeps
#   name                    = each.value.aep_name
#   relation_infra_rs_dom_p = [for domain in each.value.physical_domains : aci_physical_domain.aci_physical_domains[domain].id]
# }


# ## --------------------------- task 4 - Interface Policy Groups
# resource "aci_fabric_if_pol" "link_level_policies" {
#   for_each = var.link_level_policies
#   name     = each.value.name
#   auto_neg = contains(keys(each.value), "auto_neg") ? each.value.auto_neg : null
#   fec_mode = contains(keys(each.value), "fec_mode") ? each.value.fec_mode : null
#   speed    = contains(keys(each.value), "speed") ? each.value.speed : null
# }

# resource "aci_cdp_interface_policy" "aci_cdp_interface_policies" {
#   for_each = var.cdp_policies
#   name     = each.value.cdp_policy_name
#   admin_st = each.value.adminSt
# }

# resource "aci_lldp_interface_policy" "aci_lldp_policies" {
#   for_each    = var.lldp_policies
#   name        = each.key
#   admin_rx_st = each.value.receive_state
#   admin_tx_st = each.value.trans_state
# }

# resource "aci_lacp_policy" "lacp_policies" {
#   for_each = var.lacp_policies
#   name     = each.value.name
#   mode     = each.value.mode
# }

# resource "aci_leaf_access_port_policy_group" "aci_leaf_access_port_policy_groups" {
#   for_each                      = var.leaf_access_policy_groups
#   name                          = each.value.name
#   relation_infra_rs_att_ent_p   = contains(keys(each.value), "aep") ? aci_attachable_access_entity_profile.aci_aeps[each.value.aep].id : null
#   relation_infra_rs_cdp_if_pol  = contains(keys(each.value), "cdp_policy") ? aci_cdp_interface_policy.aci_cdp_interface_policies[each.value.cdp_policy].id : null
#   relation_infra_rs_lldp_if_pol = contains(keys(each.value), "lldp_policy") ? aci_lldp_interface_policy.aci_lldp_policies[each.value.lldp_policy].id : null
#   relation_infra_rs_h_if_pol    = contains(keys(each.value), "link_level_policy") ? aci_fabric_if_pol.link_level_policies[each.value.link_level_policy].id : null
# }

# ## --------------------------- task 5 - Profiles
# resource "aci_leaf_interface_profile" "aci_leaf_interface_profiles" {
#   for_each = var.leaf_interface_profiles
#   name     = each.value.name
# }

# resource "aci_access_port_selector" "aci_access_port_selectors" {
#   for_each                       = var.access_port_selectors
#   leaf_interface_profile_dn      = aci_leaf_interface_profile.aci_leaf_interface_profiles[each.value.leaf_interface_profile].id
#   name                           = each.value.name
#   access_port_selector_type      = contains(keys(each.value), "access_port_selector_type") ? each.value.access_port_selector_type : null
#   relation_infra_rs_acc_base_grp = contains(keys(each.value), "intf_policy") ? aci_leaf_access_port_policy_group.aci_leaf_access_port_policy_groups[each.value.intf_policy].id : null
# }

# resource "aci_access_port_block" "aci_access_port_blocks" {
#   for_each                = var.access_port_selectors
#   access_port_selector_dn = aci_access_port_selector.aci_access_port_selectors[each.key].id
#   from_card               = "1"
#   to_card                 = "1"
#   from_port               = each.value.from_port
#   to_port                 = each.value.to_port
# }

# resource "aci_leaf_profile" "aci_leaf_profiles" {
#   for_each                     = var.leaf_profiles
#   name                         = each.value.name
#   relation_infra_rs_acc_port_p = [for profile in each.value.leaf_interface_profile : aci_leaf_interface_profile.aci_leaf_interface_profiles[profile].id]
# }

# resource "aci_leaf_selector" "leaf_selectors" {
#   for_each                = var.leaf_selectors
#   leaf_profile_dn         = aci_leaf_profile.aci_leaf_profiles[each.value.leaf_profile].id
#   name                    = each.value.name
#   switch_association_type = each.value.switch_association_type
# }

# resource "aci_node_block" "node_blocks" {
#   for_each              = var.leaf_selectors
#   switch_association_dn = aci_leaf_selector.leaf_selectors[each.value.name].id
#   name                  = each.value.block
#   from_                 = each.value.block
#   to_                   = each.value.block
# }
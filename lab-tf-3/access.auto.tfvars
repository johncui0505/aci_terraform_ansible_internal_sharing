##------------------------- task 1
vlan_pools = {
  DEMO_VLAN = {
    vlan_name  = "DEMO_VLAN",
    alloc_mode = "static"
  }
}

vlan_pools_ranges = {
  DEMO_VLAN = {
    vlan_pool_name = "DEMO_VLAN",
    from           = "vlan-1000",
    to             = "vlan-4000",
    alloc_mode     = "static"
  }
}

##------------------------- task 2
physical_domains = {
  DEMO_Domain = {
    name      = "DEMO_Domain",
    vlan_pool = "DEMO_VLAN"
  }
}

##------------------------- task 3
aeps = {
  DEMO_AEP = {
    aep_name         = "DEMO_AEP",
    physical_domains = ["DEMO_Domain"]
  }
}

##------------------------- task 4
leaf_access_policy_groups = {
  Policy_1 = {
    name              = "Policy_1"
    cdp_policy        = "CDP_Disable"
    aep               = "DEMO_AEP"
    lldp_policy       = "LLDP_Disable"
    link_level_policy = "LL_10G"
  }
}

link_level_policies = {
  LL_10G = {
    name     = "10G",
    auto_neg = "off",
    speed    = "10G"
  }
}

cdp_policies = {
  CDP_Disable = {
    cdp_policy_name = "CDP_Disable",
    adminSt         = "disabled"
  }
}

lldp_policies = {
  LLDP_Disable = {
    name          = "LLDP_Disable",
    receive_state = "disabled",
    trans_state   = "disabled"
  }
}

lacp_policies = {
  LACP_Active = {
    name = "LACP_Active",
    mode = "active"
  }
}

##------------------------- task 5
leaf_interface_profiles = {
  Leaf1_Intp = {
    name = "Leaf1_Intp"
  },
  Leaf2_Intp = {
    name = "Leaf2_Intp"
  }
}

access_port_selectors = {
  Leaf1_1 = {
    leaf_interface_profile    = "Leaf1_Intp",
    name                      = "Leaf1_1",
    access_port_selector_type = "range",
    intf_policy               = "Policy_1",
    from_port                 = 1,
    to_port                   = 60
  },
  Leaf2_1 = {
    leaf_interface_profile    = "Leaf2_Intp",
    name                      = "Leaf2_1",
    access_port_selector_type = "range",
    intf_policy               = "Policy_1",
    from_port                 = 1,
    to_port                   = 60
  }
}

leaf_profiles = {
  Leaf1 = {
    name                   = "Leaf1",
    leaf_interface_profile = ["Leaf1_Intp"],
    leaf_selectors         = ["Leaf1_sel"]
  },
  Leaf2 = {
    name                   = "Leaf2",
    leaf_interface_profile = ["Leaf2_Intp"],
    leaf_selectors         = ["Leaf2_sel"]
  }
}

leaf_selectors = {
  Leaf1_sel = {
    leaf_profile            = "Leaf1",
    name                    = "Leaf1_sel",
    switch_association_type = "range",
    block                   = "1"
  },
  Leaf2_sel = {
    leaf_profile            = "Leaf2",
    name                    = "Leaf2_sel",
    switch_association_type = "range",
    block                   = "2"
  }
}
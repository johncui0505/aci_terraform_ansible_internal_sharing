tenants = {

  sample_tn = {

    tenant = {
      name = "sample_tn"
    },

    # vrfs = {
    #   idx_sample_vrf = {
    #     name = "sample_vrf"
    #   }
    # },

    # bridge_domains = {
    #   idx_bd_1 = {
    #     name    = "sample_1_bd",
    #     ref_vrf = "idx_sample_vrf"
    #   },
    #   idx_bd_2 = {
    #     name    = "sample_2_bd",
    #     ref_vrf = "idx_sample_vrf"
    #   },
    #   idx_bd_3 = {
    #     name    = "sample_3_bd",
    #     ref_vrf = "idx_sample_vrf"
    #   }
    # },

    # subnets = {
    #   idx_subnet_1 = {
    #     ref_bd = "idx_bd_1",
    #     ip     = "10.225.3.1/24",
    #     scope  = ["public"]
    #   },
    #   idx_subnet_2 = {
    #     ref_bd = "idx_bd_2",
    #     ip     = "10.225.4.1/24",
    #     scope  = ["public"]
    #   }
    #   idx_subnet_3 = {
    #     ref_bd = "idx_bd_3",
    #     ip     = "10.225.5.1/24",
    #     scope  = ["public"]
    #   }
    # },

    # app_profiles = {
    #   idx_sample_app = {
    #     name = "sample_app"
    #   }
    # },

    # epgs = {
    #   idx_sample_epg_1 = {
    #     name    = "sample1_epg",
    #     ref_epg = "idx_sample_epg_1"
    #     ref_bd  = "idx_bd_1",
    #     ref_ap  = "idx_sample_app"
    #   },
    #   idx_sample_epg_2 = {
    #     name    = "sample2_epg",
    #     ref_epg = "idx_sample_epg_2"
    #     ref_bd  = "idx_bd_2",
    #     ref_ap  = "idx_sample_app"
    #   },
    #   idx_sample_epg_3 = {
    #     name    = "sample3_epg",
    #     ref_epg = "idx_sample_epg_3"
    #     ref_bd  = "idx_bd_3",
    #     ref_ap  = "idx_sample_app"
    #   }
    # },

    # contracts = {
    #   idx_contr = {
    #     name = "sample"
    #   }
    # },

    # filters = {
    #   idx_ssh = {
    #     name = "sample"
    #   }
    # },

    # filter_subjects = {
    #   idx_filt_sub = {
    #     name         = "sample"
    #     ref_filter   = ["idx_ssh"]
    #     ref_contract = "idx_contr"
    #   }
    # },

    # filter_entries = {
    #   idx_ssh = {
    #     name           = "ssh"
    #     dest_from_port = "22"
    #     dest_to_port   = "22"
    #     ether_type     = "ipv4"
    #     protocol       = "tcp"
    #     ref_filter     = "idx_ssh"
    #   }
    # },

    # contract_bindings = {
    #   idx_cntrBind_1 = {
    #     ref_epg       = "idx_sample_epg_1"
    #     ref_contract  = "idx_contr"
    #     contract_type = "provider"
    #   }
    #   idx_cntrBind_1 = {
    #     ref_epg       = "idx_sample_epg_1"
    #     ref_contract  = "idx_contr"
    #     contract_type = "consumer"
    #   }
    # },

    # epg_to_domains = {
    #   idx_epg_to_domain_1 = {
    #     ref_epg = "idx_sample_epg_1"
    #     aci_domain_dn = "uni/phys-DEMO_Domain"
    #   },
    #   idx_epg_to_domain_2 = {
    #     ref_epg = "idx_sample_epg_2"
    #     aci_domain_dn = "uni/phys-DEMO_Domain"
    #   },
    #   idx_epg_to_domain_3 = {
    #     ref_epg = "idx_sample_epg_3"
    #     aci_domain_dn = "uni/phys-DEMO_Domain"
    #   }
    # }
  }
}
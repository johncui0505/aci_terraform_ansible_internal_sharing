# Lab 3 - 在 Fabric -> Access 创建 Resource

本 Lab 实现对以下 Resource 的创建。

- VLAN Pool
- Physical Domain
- AEP
- Interface Policy Group
- Leaf Profile
- Interface Profile

<br>

## Lab 步骤

<br>

1. 创建 VLAN Pool - 在 main.tf 文件中添加以下内容。

    ```
    resource "aci_vlan_pool" "aci_vlan_pools" {
        for_each   = var.vlan_pools
        name       = each.value.vlan_name
        alloc_mode = contains(keys(each.value), "alloc_mode") ? each.value.alloc_mode : null
        annotation = contains(keys(each.value), "annotation") ? each.value.annotation : null
    }

    resource "aci_ranges" "aci_vlan_pools_ranges" {
        for_each     = var.vlan_pools_ranges
        vlan_pool_dn = aci_vlan_pool.aci_vlan_pools[each.value.vlan_pool_name].id
        from         = contains(keys(each.value), "from") ? each.value.from : null
        to           = contains(keys(each.value), "to") ? each.value.to : null
        alloc_mode   = contains(keys(each.value), "alloc_mode") ? each.value.alloc_mode : null
        role         = contains(keys(each.value), "role") ? each.value.role : null
    }
    ```
    
    - 通过 for_each 语句，可以在一个 Resource Block 创建多个 Resource。
    - 通过 for_each 语句生成的每个 Resource 可以通过 "ResourceName['keyname']" 的方式进行访问。
    - aci_ranges.aci_vlan_pools_ranges Resource 的 vlan_pool_dn 的值是参考 aci_vlan_pool.aci_vlan_pools Resource 的 id 值。

    - 查看 access.auto.tfvars 文件中向 Resource 提供的 variable 值。

    ```
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
    ```

    - 执行 Terraform CLI，在 ACI 中查看结果。
    
    ```
    terraform init

    terraform plan

    terraform apply
    ```

<br><br>

2. 创建 ACI Physical Domain - 在 main.tf 文件中追加以下内容。

    ```
    resource "aci_physical_domain" "aci_physical_domains" {
        for_each                  = var.physical_domains
        name                      = each.value.name
        relation_infra_rs_vlan_ns = contains(keys(each.value), "vlan_pool") ? aci_vlan_pool.aci_vlan_pools[each.value.vlan_pool].id : null
    }
    ```
    - 查看 access.auto.tfvars 文件中向 Resource 提供的 variable 值。

    ```
    physical_domains = {
        DEMO_Domain = {
            name      = "DEMO_Domain",
            vlan_pool = "DEMO_VLAN"
        }
    }
    ```
    - 执行 terraform plan, terraform apply，在 ACI 中查看结果。

<br><br>

3. 生成 AEP - 在 main.tf 文件追加以下内容。

    ```
    resource "aci_attachable_access_entity_profile" "aci_aeps" {
        for_each                = var.aeps
        name                    = each.value.aep_name
        relation_infra_rs_dom_p = [for domain in each.value.physical_domains : aci_physical_domain.aci_physical_domains[domain].id]
    }
    ```
    - 通过 for 语句，循环生成需要的 List。 
    - 查看 access.auto.tfvars 文件中向 Resource 提供的 variable 值。 

    ```
    aeps = {
        DEMO_AEP = {
            aep_name         = "DEMO_AEP",
            physical_domains = ["DEMO_Domain"]
        }
    }
    ``` 
    - 执行 terraform plan, terraform apply，在 ACI 中查看结果。

<br><br>

4. 创建 Interface Policy Groups - 在 main.tf 文件中添加以下内容。

    ```
    resource "aci_fabric_if_pol" "link_level_policies" {
        for_each = var.link_level_policies
        name     = each.value.name
        auto_neg = contains(keys(each.value), "auto_neg") ? each.value.auto_neg : null
        fec_mode = contains(keys(each.value), "fec_mode") ? each.value.fec_mode : null
        speed    = contains(keys(each.value), "speed") ? each.value.speed : null
    }

    resource "aci_cdp_interface_policy" "aci_cdp_interface_policies" {
        for_each = var.cdp_policies
        name     = each.value.cdp_policy_name
        admin_st = each.value.adminSt
    }

    resource "aci_lldp_interface_policy" "aci_lldp_policies" {
        for_each    = var.lldp_policies
        name        = each.key
        admin_rx_st = each.value.receive_state
        admin_tx_st = each.value.trans_state
    }

    resource "aci_lacp_policy" "lacp_policies" {
        for_each = var.lacp_policies
        name     = each.value.name
        mode     = each.value.mode
    }

    resource "aci_leaf_access_port_policy_group" "aci_leaf_access_port_policy_groups" {
        for_each                      = var.leaf_access_policy_groups
        name                          = each.value.name
        relation_infra_rs_att_ent_p   = contains(keys(each.value), "aep")               ? aci_attachable_access_entity_profile.aci_aeps[each.value.aep].id : null
        relation_infra_rs_cdp_if_pol  = contains(keys(each.value), "cdp_policy")        ? aci_cdp_interface_policy.aci_cdp_interface_policies[each.value.cdp_policy].id : null
        relation_infra_rs_lldp_if_pol = contains(keys(each.value), "lldp_policy")       ? aci_lldp_interface_policy.aci_lldp_policies[each.value.lldp_policy].id : null
        relation_infra_rs_h_if_pol    = contains(keys(each.value), "link_level_policy") ? aci_fabric_if_pol.link_level_policies[each.value.link_level_policy].id : null
    }
    ```
    - 在 access.auto.tfvars 文件中查看要调取的 variable 值。

    ```
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
    ``` 
    - terraform plan, terraform apply를 실행하고, ACI에서 결과를 확인합니다.

<br><br>

5. 创建 Profiles - 在 main.tf 文件中添加以下内容。

    ```
    resource "aci_leaf_interface_profile" "aci_leaf_interface_profiles" {
        for_each = var.leaf_interface_profiles
        name     = each.value.name
    }

    resource "aci_access_port_selector" "aci_access_port_selectors" {
        for_each                       = var.access_port_selectors
        leaf_interface_profile_dn      = aci_leaf_interface_profile.aci_leaf_interface_profiles[each.value.leaf_interface_profile].id
        name                           = each.value.name
        access_port_selector_type      = contains(keys(each.value), "access_port_selector_type") ? each.value.access_port_selector_type : null
        relation_infra_rs_acc_base_grp = contains(keys(each.value), "intf_policy") ? aci_leaf_access_port_policy_group.aci_leaf_access_port_policy_groups[each.value.intf_policy].id : null
    }

    resource "aci_access_port_block" "aci_access_port_blocks" {
        for_each                = var.access_port_selectors
        access_port_selector_dn = aci_access_port_selector.aci_access_port_selectors[each.key].id
        from_card               = "1"
        to_card                 = "1"
        from_port               = each.value.from_port
        to_port                 = each.value.to_port
    }

    resource "aci_leaf_profile" "aci_leaf_profiles" {
        for_each                     = var.leaf_profiles
        name                         = each.value.name
        relation_infra_rs_acc_port_p = [for profile in each.value.leaf_interface_profile : aci_leaf_interface_profile.aci_leaf_interface_profiles[profile].id]
    }

    resource "aci_leaf_selector" "leaf_selectors" {
        for_each                = var.leaf_selectors
        leaf_profile_dn         = aci_leaf_profile.aci_leaf_profiles[each.value.leaf_profile].id
        name                    = each.value.name
        switch_association_type = each.value.switch_association_type
    }

    resource "aci_node_block" "node_blocks" {
        for_each              = var.leaf_selectors
        switch_association_dn = aci_leaf_selector.leaf_selectors[each.value.name].id
        name                  = each.value.block
        from_                 = each.value.block
        to_                   = each.value.block
    }
    ```

    - 在 access.auto.tfvars 文件中查看要调取的 variable 值。

    ```
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
    ``` 
    - 执行 terraform plan, terraform apply，在 ACI 中查看结果。

<br><br>

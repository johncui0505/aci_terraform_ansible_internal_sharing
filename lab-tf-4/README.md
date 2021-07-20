# Lab 4 - 创建 Tenant

本 Lab 是通过创建并使用 Terraform Module 来实现 Tenant 的创建。

<br><br>

## Lab 步骤

<br>

1. 查看 main.tf 文件内容。

```
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

module "tenant" {
  source   = "./module/tenant"
  for_each = var.tenants
  tenant   = each.value
}

output "tenant" {
  value = module.tenant
}
```

- module 是一个把要重复使用的 terraform 脚本存储的目录。可以在本地创建一个 module 文件夹，也可以直接使用 Terraform Registry 的 module。
- output.tf 是为了存储执行结果，也可以让其他 Resource 调用该 output 中的数据。

<br><br>

2. 查看 module 目录树。
```
module/
`-- tenant
    |-- main.tf
    |-- output.tf
    `-- variables.tf
```
- tenant module 由 main.tf, output.tf, variable.tf 文件构成。

<br><br>

2. 查看 module/tenant/main.tf 文件内容。

```
...

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

...
```
- 通过 locals 方法，把在脚本中重复使用的数据预先编写好来使用。 
- locals 里的数据是从 root module 的 tenants variable 文件中调取。

<br><br>

4. tenant.auto.tfvars 文件中会设定传给 module "tenant" 的 variable "tenant" 的值。tenant.auto.tfvars 的内容如下。
```
tenants = {

  tenant_1 = {
    tenant = { ... },
    vrfs = { ... }
    bridge_domains = { ... }
    subnets = { ... }
    app_profiles = { ... }
    epgs = { ... }
    contracts = { ... }
    ...
  },

  tenant_2 = {
    ...
  },
  ...

  tenant_N = {
    ...
  }

}
```
- 在 tenants variable 中设定要传给 tenant module 的参数值。
- tenants 里面的参数是每个 tenant 里被使用的 Resource 的参数值。
- 在 tenants variable 中科院包含多个 tenant。

<br><br>

5. tenant.auto.tfvars 添加以下内容来部署 tenant。
```
tenants = {

  sample_tn = {

    tenant = {
      name = "sample_tn"
    }

  }

}
```
- 执行 terraform init，terraform plan， terraform apply，并在 ACI 中确认结果。 


<br><br>

6. 在创建的 tenant 中添加 vrf 和 bridge domain 并部署到 ACI。

```
tenants = {

  sample_tn = {

    tenant = {
      name = "sample_tn"
    },

    # -----------------------------> 从这里开始添加
    vrfs = {
      idx_sample_vrf = {
        name = "sample_vrf"
      }
    },

    bridge_domains = {  
      idx_bd_1 = {
        name    = "sample_1_bd",
        ref_vrf = "idx_sample_vrf"
      },
      idx_bd_2 = {
        name    = "sample_2_bd",
        ref_vrf = "idx_sample_vrf"
      },
      idx_bd_3 = {
        name    = "sample_3_bd",
        ref_vrf = "idx_sample_vrf"
      }
    },

    subnets = {
      idx_subnet_1 = {
        ref_bd = "idx_bd_1",
        ip     = "10.225.3.1/24",
        scope  = ["public"]
      },
      idx_subnet_2 = {
        ref_bd = "idx_bd_2",
        ip     = "10.225.4.1/24",
        scope  = ["public"]
      }
      idx_subnet_3 = {
        ref_bd = "idx_bd_3",
        ip     = "10.225.5.1/24",
        scope  = ["public"]
      }
    }   
    # -----------------------------> 添加到这里
  }
}
```
- bridge domain, subnet 中会参考上级 Resource 的参数值。 (例如: Bridge Domain "sample_1_bd" 会参考 "sample_vrf" VRF。)
- 执行 terraform plan, terraform apply，并在 ACI 中确认结果。 

<br><br>

7. 在 tenant.auto.tfvars 文件中添加 Application Profile 和 EPG，并部署到 ACI 中。

```
...
    app_profiles = {
      idx_sample_app = {
        name = "sample_app"
      }
    },

    epgs = {
      idx_sample_epg_1 = {
        name    = "sample1_epg",
        ref_epg = "idx_sample_epg_1"
        ref_bd  = "idx_bd_1",
        ref_ap  = "idx_sample_app"
      },
      idx_sample_epg_2 = {
        name    = "sample2_epg",
        ref_epg = "idx_sample_epg_2"
        ref_bd  = "idx_bd_2",
        ref_ap  = "idx_sample_app"
      },
      idx_sample_epg_3 = {
        name    = "sample3_epg",
        ref_epg = "idx_sample_epg_3"
        ref_bd  = "idx_bd_3",
        ref_ap  = "idx_sample_app"
      }
    }
...
```
- 执行 terraform plan, terraform apply，并在 ACI 中确认结果。  

<br><br>

8. 在 tenant.auto.tfvars 文件中添加 Contract, Subject, Filter 内容，并部署到 ACI 中。

```
...
    contracts = {
      idx_contr = {
        name = "default"
      }
    },
    
    filters = {
      idx_ssh = {
        name = "default"
      }
    },

    filter_subjects = {
      idx_filt_sub = {
        name         = "default"
        ref_filter   = ["idx_ssh"]
        ref_contract = "idx_contr"
      }
    },

    filter_entries = {
      idx_ssh = {
        name           = "ssh"
        dest_from_port = "22"
        dest_to_port   = "22"
        ether_type     = "ipv4"
        protocol       = "tcp"
        ref_filter     = "idx_ssh"
      }
    },

    contract_bindings = {
      idx_cntrBind_1 = {
        ref_epg       = "idx_sample_epg_1"
        ref_contract  = "idx_contr"
        contract_type = "provider"
      }
      idx_cntrBind_1 = {
        ref_epg       = "idx_sample_epg_1"
        ref_contract  = "idx_contr"
        contract_type = "consumer"
      }
    },
...
```
- 执行 terraform plan, terraform apply，并在 ACI 中确认结果。

<br><br>

9. 为了关联 EPG 和 Domain，在 tenant.auto.tfvars 追加以下内容，并在 ACI 中部署。

```
    epg_to_domains = {
      idx_epg_to_domain_1 = {
        ref_epg = "idx_sample_epg_1"
        aci_domain_dn = "uni/phys-DEMO_Domain"
      },
      idx_epg_to_domain_2 = {
        ref_epg = "idx_sample_epg_2"
        aci_domain_dn = "uni/phys-DEMO_Domain"
      },
      idx_epg_to_domain_3 = {
        ref_epg = "idx_sample_epg_3"
        aci_domain_dn = "uni/phys-DEMO_Domain"
      }
    }
```
- 执行 terraform plan, terraform apply，并在 ACI 中确认结果。

<br><br>

10. 现在要追加一个 Tenant。在 tenant.auto.tfvars 文件中把 sample_tn block 复制，并且粘贴到 tenants variable 里面。然后把粘贴的内容中的 Tenant Name 部分改为 "sample2_tn"。

```
tenants = {

  sample_tn = {
    ...
  }

  sample2_tn = {            # sample_tn에서 sample2_tn으로 수정됨

    tenant = {
      name = "sample2_tn"   # sample_tn에서 sample2_tn으로 수정됨
    },
    ...
  }

}
```
- 执行 terraform plan, terraform apply，并在 ACI 中确认结果。

<br><br>


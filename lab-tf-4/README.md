# Lab 4 - Tenant 생성

본 시나리오에서는 Tenant 리소스를 생성하는 Terraform 모듈과 스크립트를 작성합니다.

<br><br>

## Lab 진행 순서  

<br>

1. main.tf 파일 내용을 살펴봅니다.

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

- module은 재사용 가능한 terraform 스크립트의 모음으로, 로컬 환경의 다른 작업 디렉토리에 위치하거나, Terraform Registry의 module을 현재의 작업 디렉토리에서 사용할 수 있습니다.
- output은 실행 결과를 별도의 출력으로 콘솔에 보여주거나, 다른 리소스에서 참조하기 위하여 사용합니다.

<br><br>

2. module의 구조를 살펴봅니다.
```
module/
`-- tenant
    |-- main.tf
    |-- output.tf
    `-- variables.tf
```
- tenant module은 main.tf, output.tf, variable.tf로 구성되어 있습니다. 

<br><br>

2. module/tenant/main.tf 파일을 살펴봅니다.

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
- locals 를 이용하여 스크립트 내에서 반복적으로 사용되는 값을 선언할 수 있습니다. 
- locals의 각 값은 root module의 tenants variable 으로부터 전달받아 할당됩니다.

<br><br>

4. tenant.auto.tfvars 파일에는 module "tenant"로 전달할 variable "tenant"의 값을 설정합니다. tenant.auto.tfvars는 아래와 같은 형식을 갖습니다.
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
- tenants variable에는 tenant module로 전달할 설정값을 작성합니다.
- tenants에 속한 각각의 객체는 하나의 테넌트와 테넌트의 하위 리소스를 나타냅니다.
- tenants variable에 다수의 tenant를 포함시킬 수 있습니다.

<br><br>

5. tenant.auto.tfvars를 아래와 같이 작성하고 tenent를 배포합니다.
```
tenants = {

  sample_tn = {

    tenant = {
      name = "sample_tn"
    }

  }

}
```
- terraform init, terraform plan, terraform apply 를 실행하고, 실행 결과를 ACI에서 확인합니다. 


<br><br>

6. 생성된 tenant에 vrf와 domain bridge를 추가하여 배포합니다.

```
tenants = {

  sample_tn = {

    tenant = {
      name = "sample_tn"
    },

    # -----------------------------> 여기서부터 추가됨
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
    # -----------------------------> 여기까지 추가됨
  }
}
```
- bridge domain, subnet 항목에서 각각 상위 리소스의 값을 참조하고 있습니다. (예: Domain bridge "sample_1_bd"는 VRF "sample_vrf"를 참조합니다.)
- terraform plan, terraform apply 를 실행하고, 실행 결과를 ACI에서 확인합니다. 

<br><br>

7. Application Profile 과 EPG를 tenant.auto.tfvars 에 추가하고, ACI 에 배포합니다.

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
- terraform plan, terraform apply 를 실행하고, 실행 결과를 ACI에서 확인합니다. 

<br><br>

8. Contract, Subject, Filter를 tenant.auto.tfvars 에 추가하고, ACI 에 배포합니다.

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
- terraform plan, terraform apply 를 실행하고, 실행 결과를 ACI에서 확인합니다. 

<br><br>

9. EPG에 Domain을 연결하기 위하여 tenant.auto.tfvars 에 추가하고, ACI 에 배포합니다.

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
- terraform plan, terraform apply 를 실행하고, 실행 결과를 ACI에서 확인합니다. 

<br><br>

10. 새로운 Tenant을 추가하고자 합니다. tenant.auto.tfvars 에서 sample_tn 블록 전체를 복사하여, tenants variable 안에 새로 붙여넣습니다. 그리고나서, 새로 붙여넣은 블록의 키와 테넌트 이름을 "sample2_tn"으로 수정합니다.

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
- terraform plan, terraform apply 를 실행하고, 실행 결과를 ACI에서 확인합니다. 

<br><br>


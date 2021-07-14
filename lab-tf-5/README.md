# Lab 5 - 创建 Static Port

通过本 Lab 在 ACI 中来创建 Static Port。

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

resource "aci_epg_to_static_path" "aci_static_path" {
  for_each           = var.epg_static_paths
  application_epg_dn = format("uni/tn-%s/ap-%s/epg-%s", each.value.tenant, each.value.ap, each.value.epg)
  tdn                = format("topology/pod-%s/paths-%s/pathep-[%s]", each.value.pod, each.value.node, each.value.port)
  encap              = each.value.encap
  instr_imedcy       = each.value.deployment_immediacy
  mode               = each.value.mode
}
```
- 通过 format() 函数得到想要的格式。

<br><br>

2. 进行 Static Port 生成操作时，不是编写每一个接口的创建语句，而是通过把 Excel 文件中存储的接口信息导出为 .tfvars 文件，最终通过调用该变量文件来实现整个创建操作。首先查看 Excel 文件内容。
- files/static_ports.xlsx 

    ![](../images/lab-tf-5/lab-tf-5-1.png)

3. 通过 Python 脚本把该 Excel 文件导出为我们想要的 static_port.auto.tfvars 文件。

```
cd files
python static_port.py
```

4. 查看新生成的 static_ports.auto.tfvars 文件。

```
epg_static_paths = { 

  idx_static_port_1 = {
    tenant               = "sample_tn",
    ap                   = "sample_app",
    epg                  = "sample1_epg",
    pod                  = "1",
    node                 = "101",
    port                 = "eth1/1",
    encap                = "vlan-1000",
    deployment_immediacy = "immediate",
    mode                 = "untagged"
  },
  idx_static_port_2 = {
    tenant               = "sample_tn",
    ap                   = "sample_app",
    epg                  = "sample1_epg",
    pod                  = "1",
    node                 = "101",
    port                 = "eth1/2",
    encap                = "vlan-1000",
    deployment_immediacy = "immediate",
    mode                 = "untagged"
  },

  ...
  
  idx_static_port_41 = {
    tenant               = "sample_tn",
    ap                   = "sample_app",
    epg                  = "sample1_epg",
    pod                  = "1",
    node                 = "101",
    port                 = "eth1/41",
    encap                = "vlan-1000",
    deployment_immediacy = "immediate",
    mode                 = "untagged"
  },
}
```

5. 通过以上的变量信息来创建 static port。

```
terraform init

terraform plan

terraform apply
```
- 执行完在 ACI 中查看结果。

    ![](../images/lab-tf-5/lab-tf-5-2.png)

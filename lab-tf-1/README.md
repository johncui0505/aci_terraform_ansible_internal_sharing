# Lab 1 - Terraform CLI 命令

通过Lab，熟悉 Terraform 基本命令及操作。

- terraform init 命令
- terraform plan 命令
- terraform apply 命令
- variable 使用方法
- terraform destroy 命令

<br>

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
        username = var.aci_user
        password = var.aci_pw
        url      = var.aci_url
        insecure = var.aci_https
    }

    resource "aci_tenant" "my_tenant" {
        name = "MyFirstTenant"
        # description = "Created by terraform"
    }
    ```

<br>

2. 初始化工作目录。
    ```
    terraform init
    ```

<br>

3. 执行terraform plan命令，并查看结果


<br>

4. 执行terraform apply命令以实现 Tenant 的创建。
    ```
    terraform apply 
    ```

<br>

5. 在 ACI 中查看创建的 Tenant 信息。(Tenant > All TENANTS)

    ![lab1_1](../images/lab-tf-1/1.png)

<br>

6. 把 main.tf 文件中的第20行前面的 # 去掉，然后执行 terraform plan，并且指定变量存储的文件名称（variable.tfvars）。

    - 变更前
        ```
        resource "aci_tenant" "my_tenant" {
            name = "MyFirstTenant"
            # description = "Created by terraform"
        }
        ```
    - 变更后
        ```
        resource "aci_tenant" "my_tenant" {
            name = "MyFirstTenant"
            description = "Created by terraform"
        }
        ```

    ```
    terraform plan -var-file variable.tfvars
    ```
    - -var-file 选项是指定 .tf文件中使用的变量存储的文件。
    - 执行 Plan 后发现，只有 "MyFirstTenant" Tenant 的 Description 部分被添加，Tenant本身并没有发生Deleted, Recreated 操作。

<br>

7. 执行 terraform apply 来进行下发操作。

    ```
    terraform apply -var-file variable.tfvars -auto-approve
    ```
    - 添加 -auto-approve 选项，可以自动跳过 approve 确认，直接进行 Terraform apply 的操作。

<br>

8. 在 ACI 中查看更新的内容。

    ![lab1_3](../images/lab-tf-1/3.png)

<br>

9. 通过 destroy，删除所有通过 Terraform 创建的 Resource。

    ```
    terraform destroy -var-file variable.tfvars
    ```

<br>

10. 在 ACI 中查看是否删除成功。

    ![lab1_5](../images/lab-tf-1/5.png)

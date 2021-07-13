# Ansible Lab #2 - Ansible 调用 ACI REST API

<br><br>

## Lab 步骤

<br>

1. Inventory 文件内容：

- Inventory 文件 (hosts)

```
[aci] 
apic

[aci:vars]
aci_host=198.18.133.200
aci_port=443
aci_user=admin
aci_password=C1sco12345
aci_valid_cert=false
aci_use_ssl=true
```

<br><br>

2. Playbook 文件内容：
- main.yml

```yaml
- hosts: aci
  connection: local
  gather_facts: no

  tasks:
    - name: API 查询 - 所有接口状态
      aci_rest:
        host:           "{{ aci_host }}" 
        user:           "{{ aci_user }}" 
        password:       "{{ aci_password }}" 
        validate_certs: "{{ aci_valid_cert }}" 
        use_ssl:        "{{ aci_use_ssl }}" 
        path:       /api/class/ethpmPhysIf.json
        method:     get
      register: ethpmPhysIf

    - name: 输出结果为JSON文件
      copy: 
        content: "{{ ethpmPhysIf | to_nice_json }}"
        dest: ethpmPhysIf_full.json
```

<br><br>

3. 执行 Playbook 

```
ansible-playbook -i hosts main.yml
```

<br><br>

4. 查看通过 Playbook 生成的 ethpmPhysIf_full.json 文件。

```json
{
    "ansible_facts": { ... },
    "changed": false,
    "failed": false,
    "imdata": [
        {
            "ethpmPhysIf": {
                "attributes": {
                    ...
                    "dn": "topology/pod-1/node-101/sys/phys-[eth1/45]/phys",
                    ...
                    "operDceMode": "off",
                    "operDuplex": "auto",
                    "operEEERxWkTime": "0",
                    "operEEEState": "not-applicable",
                    "operEEETxWkTime": "0",
                    "operErrDisQual": "admin-down",
                    "operFecMode": "inherit",
                    "operFlowCtrl": "15",
                    "operMdix": "auto",
                    "operMode": "trunk",
                    "operModeDetail": "trunk",
                    "operPhyEnSt": "down",
                    "operRouterMac": "00:00:00:00:00:00",
                    "operSpeed": "inherit",
                    "operSt": "down",
                    ...
                }
            }
        },
        {
            "ethpmPhysIf": {
                "attributes": {
                    ...
                    "dn": "topology/pod-1/node-101/sys/phys-[eth1/29]/phys",
                    ...
                }
            }
        },
        ...

    ]
}
```

<br><br>

5. 修改Playbook内容，来实现对于特定内容的读取。
- 在main.yml 追加如下内容，实现只针对 Interface 的 dn, operSt, operMode, operSpeed 信息的读取，并保存到JSON文件中。
```yaml
    - name: 只查询特定内容并保存为JSON文件
      copy: 
        content: "{{ ethpmPhysIf | json_query('
          imdata[].ethpmPhysIf.attributes.{
            dn:dn, 
            operSt:operSt, 
            operMode:operMode, 
            operSpeed:operSpeed}') | to_nice_json }}"
        dest: ethpmPhysIf_custom.json
```

<br><br>

6. 重新执行Playbook。

```
ansible-playbook -i hosts main.yml
```

<br><br>

7. 查看新生成的 ethpmPhysIf_custom.json 文件。

```json
[
    {
        "dn": "topology/pod-1/node-101/sys/phys-[eth1/45]/phys",
        "operMode": "trunk",
        "operSpeed": "inherit",
        "operSt": "down"
    },
    {
        "dn": "topology/pod-1/node-101/sys/phys-[eth1/29]/phys",
        "operMode": "trunk",
        "operSpeed": "inherit",
        "operSt": "down"
    },
    {
        "dn": "topology/pod-1/node-101/sys/phys-[eth1/46]/phys",
        "operMode": "trunk",
        "operSpeed": "inherit",
        "operSt": "down"
    },
    ...
]
```

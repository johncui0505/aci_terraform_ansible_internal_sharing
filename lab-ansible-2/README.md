# Ansible Lab #2 - Ansible과 ACI REST API 활용하기

<br><br>

## Lab 진행 순서  

<br>

1. 인벤토리 파일을 살펴봅니다.

- Inventory 파일 (hosts)

```
[aci] 
apic

[aci:vars]
aci_host=apic1.dcloud.cisco.com
aci_port=443
aci_user=admin
aci_password=C1sco12345
aci_valid_cert=false
aci_use_ssl=true
```

<br><br>

2. Playbook 파일을 살펴봅니다.
- main.yml

```yaml
- hosts: aci
  connection: local
  gather_facts: no

  tasks:
    - name: API 호출 - 모든 인터페이스 상태 수집
      aci_rest:
        host:           "{{ aci_host }}" 
        user:           "{{ aci_user }}" 
        password:       "{{ aci_password }}" 
        validate_certs: "{{ aci_valid_cert }}" 
        use_ssl:        "{{ aci_use_ssl }}" 
        path:       /api/class/ethpmPhysIf.json
        method:     get
      register: ethpmPhysIf

    - name: 수집 결과를 Json 파일로 저장
      copy: 
        content: "{{ ethpmPhysIf | to_nice_json }}"
        dest: ethpmPhysIf_full.json
```

<br><br>

3. Playbook을 실행합니다.

```
ansible-playbook -i hosts main.yml
```

<br><br>

4. Playbook 실행 결과로 생성된 ethpmPhysIf_full.json 파일을 살펴봅니다.

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

5. 특정 정보만을 가져오도록 playbook을 수정합니다.
- 아래 내용을 main.yml에 추가하여, 각 인터페이스에 대한 dn, operSt, operMode, operSpeed 정보 만을 Json 파일로 저장합니다.
```yaml
    - name: 수집 결과를 Json 파일로 저장 및 특정 값만 조회
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

6. Playbook을 다시 실행합니다.

```
ansible-playbook -i hosts main.yml
```

<br><br>

7. Playbook 실행 결과로 새로 생성된 ethpmPhysIf_custom.json 파일을 살펴봅니다.

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
